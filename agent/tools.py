import os
from datetime import datetime
from typing import Optional

from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()


def _get_supabase() -> Client:
    """Lazy Supabase client — only connects when a tool is actually called."""
    url = os.environ.get("SUPABASE_URL", "")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
    if not url or not key:
        raise RuntimeError("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
    return create_client(url, key)


def get_services(category: Optional[str] = None) -> dict:
    """Retrieve available car wash services, optionally filtered by category.

    Args:
        category: Filter by service category (e.g. "wash", "detail", "addon").
                  If None, returns all services.
    """
    sb = _get_supabase()
    query = sb.table("services").select("*").eq("is_active", True)
    if category:
        query = query.eq("category", category)
    result = query.execute()
    return {"services": result.data}


def get_membership_info(tier: Optional[str] = None) -> dict:
    """Retrieve membership plan details, optionally filtered by plan name.

    Args:
        tier: Specific membership plan name (e.g. "Silver", "Gold", "Platinum").
              If None, returns all plans.
    """
    sb = _get_supabase()
    query = sb.table("membership_plans").select("*")
    if tier:
        query = query.ilike("name", f"%{tier}%")
    result = query.execute()
    return {"membership_plans": result.data}


def check_availability(location_id: str, date: str, service_id: str) -> dict:
    """Check available appointment slots for a given location, date, and service.

    Args:
        location_id: The ID of the car wash location.
        date: The date to check in YYYY-MM-DD format.
        service_id: The ID of the desired service.
    """
    sb = _get_supabase()
    # Get existing bookings for that date/location
    result = (
        sb.table("bookings")
        .select("scheduled_at")
        .eq("location_id", location_id)
        .eq("status", "confirmed")
        .gte("scheduled_at", f"{date}T00:00:00")
        .lte("scheduled_at", f"{date}T23:59:59")
        .execute()
    )
    booked_slots = [row["scheduled_at"] for row in result.data]

    # Get location hours
    loc_result = (
        sb.table("locations")
        .select("name, hours")
        .eq("id", location_id)
        .single()
        .execute()
    )

    return {
        "date": date,
        "location_id": location_id,
        "booked_slots": booked_slots,
        "location": loc_result.data,
    }


def book_appointment(
    customer_phone: str,
    location_id: str,
    service_id: str,
    datetime_str: str,
    vehicle_info: str,
) -> dict:
    """Book a car wash appointment.

    Args:
        customer_phone: Customer's phone number.
        location_id: The ID of the car wash location.
        service_id: The ID of the selected service.
        datetime_str: Appointment date and time in ISO 8601 format.
        vehicle_info: Description of the vehicle (e.g. "Red Toyota Camry").
    """
    sb = _get_supabase()

    # Look up customer by phone
    cust_result = (
        sb.table("customers")
        .select("id")
        .eq("phone", customer_phone)
        .execute()
    )
    customer_id = cust_result.data[0]["id"] if cust_result.data else None

    record = {
        "customer_id": customer_id,
        "location_id": location_id,
        "service_id": service_id,
        "scheduled_at": datetime_str,
        "vehicle_info": vehicle_info,
        "status": "confirmed",
    }
    result = sb.table("bookings").insert(record).execute()
    return {"appointment": result.data[0] if result.data else None}


def cancel_appointment(
    appointment_id: str, reason: Optional[str] = None
) -> dict:
    """Cancel an existing appointment.

    Args:
        appointment_id: The ID of the appointment to cancel.
        reason: Optional reason for cancellation.
    """
    sb = _get_supabase()
    update = {"status": "cancelled"}
    if reason:
        update["notes"] = reason
    result = (
        sb.table("bookings")
        .update(update)
        .eq("id", appointment_id)
        .execute()
    )
    return {"cancelled": result.data[0] if result.data else None}


def lookup_customer(query: str, search_by: str = "phone") -> dict:
    """Look up a customer record by phone number or name.

    Args:
        query: The search value (phone number or name).
        search_by: Field to search — "phone" or "name". Defaults to "phone".
    """
    sb = _get_supabase()
    if search_by == "phone":
        result = sb.table("customers").select("*").eq("phone", query).execute()
    elif search_by == "name":
        result = sb.table("customers").select("*").ilike("name", f"%{query}%").execute()
    else:
        return {"error": f"Invalid search_by value: {search_by}"}
    return {"customers": result.data}


def file_complaint(
    description: str,
    category: str,
    customer_phone: Optional[str] = None,
    appointment_id: Optional[str] = None,
) -> dict:
    """File a customer complaint.

    Args:
        description: Detailed description of the complaint.
        category: Complaint category (e.g. "damage", "quality", "wait_time",
                  "billing", "staff", "other").
        customer_phone: Optional phone number of the customer filing the complaint.
        appointment_id: Optional related appointment ID.
    """
    sb = _get_supabase()

    # Look up customer if phone provided
    customer_id = None
    if customer_phone:
        cust_result = sb.table("customers").select("id").eq("phone", customer_phone).execute()
        customer_id = cust_result.data[0]["id"] if cust_result.data else None

    record = {
        "description": description,
        "category": category,
        "status": "open",
    }
    if customer_id:
        record["customer_id"] = customer_id
    if appointment_id:
        record["booking_id"] = appointment_id

    result = sb.table("complaints").insert(record).execute()
    return {"complaint": result.data[0] if result.data else None}


def get_operating_hours(location_id: Optional[str] = None) -> dict:
    """Get operating hours for one or all locations.

    Args:
        location_id: Specific location ID. If None, returns hours for all locations.
    """
    sb = _get_supabase()
    query = sb.table("locations").select("id, name, address, phone, hours")
    if location_id:
        query = query.eq("id", location_id)
    result = query.execute()
    return {"locations": result.data}
