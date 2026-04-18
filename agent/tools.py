import os
from datetime import datetime
from typing import Optional

from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

supabase: Client = create_client(
    os.environ["SUPABASE_URL"],
    os.environ["SUPABASE_SERVICE_ROLE_KEY"],
)


def get_services(category: Optional[str] = None) -> dict:
    """Retrieve available car wash services, optionally filtered by category.

    Args:
        category: Filter by service category (e.g. "wash", "detail", "addon").
                  If None, returns all services.
    """
    query = supabase.table("services").select("*")
    if category:
        query = query.eq("category", category)
    result = query.execute()
    return {"services": result.data}


def get_membership_info(tier: Optional[str] = None) -> dict:
    """Retrieve membership plan details, optionally filtered by tier.

    Args:
        tier: Specific membership tier (e.g. "basic", "premium", "unlimited").
              If None, returns all tiers.
    """
    query = supabase.table("memberships").select("*")
    if tier:
        query = query.eq("tier", tier)
    result = query.execute()
    return {"memberships": result.data}


def check_availability(location_id: str, date: str, service_id: str) -> dict:
    """Check available appointment slots for a given location, date, and service.

    Args:
        location_id: The ID of the car wash location.
        date: The date to check in YYYY-MM-DD format.
        service_id: The ID of the desired service.
    """
    result = supabase.table("appointments").select("datetime_slot").match(
        {"location_id": location_id, "service_id": service_id}
    ).gte("datetime_slot", f"{date}T00:00:00").lte(
        "datetime_slot", f"{date}T23:59:59"
    ).execute()

    booked_slots = [row["datetime_slot"] for row in result.data]

    # Fetch location operating hours to compute available slots
    hours_result = supabase.table("locations").select(
        "opening_time, closing_time"
    ).eq("id", location_id).single().execute()

    return {
        "date": date,
        "location_id": location_id,
        "booked_slots": booked_slots,
        "operating_hours": hours_result.data,
    }


def book_appointment(
    customer_phone: str,
    location_id: str,
    service_id: str,
    datetime_str: str,
    vehicle_info: dict,
) -> dict:
    """Book a car wash appointment.

    Args:
        customer_phone: Customer's phone number.
        location_id: The ID of the car wash location.
        service_id: The ID of the selected service.
        datetime_str: Appointment date and time in ISO 8601 format.
        vehicle_info: Dict with keys like "make", "model", "color".
    """
    record = {
        "customer_phone": customer_phone,
        "location_id": location_id,
        "service_id": service_id,
        "datetime_slot": datetime_str,
        "vehicle_make": vehicle_info.get("make"),
        "vehicle_model": vehicle_info.get("model"),
        "vehicle_color": vehicle_info.get("color"),
        "status": "confirmed",
        "created_at": datetime.utcnow().isoformat(),
    }
    result = supabase.table("appointments").insert(record).execute()
    return {"appointment": result.data[0] if result.data else None}


def cancel_appointment(
    appointment_id: str, reason: Optional[str] = None
) -> dict:
    """Cancel an existing appointment.

    Args:
        appointment_id: The ID of the appointment to cancel.
        reason: Optional reason for cancellation.
    """
    update = {"status": "cancelled"}
    if reason:
        update["cancellation_reason"] = reason
    result = (
        supabase.table("appointments")
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
    if search_by == "phone":
        result = (
            supabase.table("customers")
            .select("*")
            .eq("phone", query)
            .execute()
        )
    elif search_by == "name":
        result = (
            supabase.table("customers")
            .select("*")
            .ilike("name", f"%{query}%")
            .execute()
        )
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
        category: Complaint category (e.g. "service_quality", "wait_time",
                  "damage", "staff", "billing", "other").
        customer_phone: Optional phone number of the customer filing the complaint.
        appointment_id: Optional related appointment ID.
    """
    record = {
        "description": description,
        "category": category,
        "status": "open",
        "created_at": datetime.utcnow().isoformat(),
    }
    if customer_phone:
        record["customer_phone"] = customer_phone
    if appointment_id:
        record["appointment_id"] = appointment_id

    result = supabase.table("complaints").insert(record).execute()
    return {"complaint": result.data[0] if result.data else None}


def get_operating_hours(location_id: Optional[str] = None) -> dict:
    """Get operating hours for one or all locations.

    Args:
        location_id: Specific location ID. If None, returns hours for all locations.
    """
    query = supabase.table("locations").select(
        "id, name, address, opening_time, closing_time, days_open"
    )
    if location_id:
        query = query.eq("id", location_id)
    result = query.execute()
    return {"locations": result.data}
