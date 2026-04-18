-- seed.sql
-- Rich realistic seed data for Crystal Clear Car Wash (San Jose, CA)

-- ============================================================
-- Services (12 services)
-- ============================================================
insert into services (id, name, description, price_cents, duration_minutes, category, is_active) values
  (gen_random_uuid(), 'Basic Exterior', 'Exterior hand wash with spot-free rinse and hand dry. Gets the road grime off quickly.', 1200, 15, 'wash', true),
  (gen_random_uuid(), 'Standard Wash', 'Full exterior wash plus window cleaning, tire dressing, and dashboard wipe-down.', 1800, 25, 'wash', true),
  (gen_random_uuid(), 'Premium Full', 'Complete interior and exterior wash. Includes vacuuming, interior wipe-down, window cleaning, and tire shine.', 2500, 40, 'wash', true),
  (gen_random_uuid(), 'The Works', 'Our top-tier wash package. Everything in Premium Full plus hand wax, leather conditioning, and air freshener.', 4500, 60, 'wash', true),
  (gen_random_uuid(), 'Express Vacuum', 'Quick interior vacuum of seats, floors, and trunk. Perfect between full washes.', 1500, 15, 'detail', true),
  (gen_random_uuid(), 'Full Interior Detail', 'Deep clean of all interior surfaces. Steam cleaning, shampooing carpets, conditioning leather, and sanitizing.', 5500, 90, 'detail', true),
  (gen_random_uuid(), 'Complete Detail', 'The ultimate treatment. Full interior detail plus clay bar, polish, and hand wax on exterior. Your car will look showroom new.', 8900, 150, 'detail', true),
  (gen_random_uuid(), 'Ceramic Coating', 'Professional-grade ceramic coating application. Provides long-lasting protection and incredible shine for 6-12 months.', 15000, 180, 'detail', true),
  (gen_random_uuid(), 'Express Wax', 'Quick spray wax application after any wash. Adds a layer of protection and extra shine.', 1500, 15, 'addon', true),
  (gen_random_uuid(), 'Tire Shine', 'Premium tire dressing that gives your tires a deep, rich black finish.', 800, 10, 'addon', true),
  (gen_random_uuid(), 'Air Freshener', 'Long-lasting premium air freshener. Choose from Ocean Breeze, New Car, Vanilla, or Lavender.', 500, 5, 'addon', true),
  (gen_random_uuid(), 'Headlight Restoration', 'Restore cloudy, yellowed headlights to crystal clear. Improves visibility and appearance.', 4500, 45, 'addon', true);

-- ============================================================
-- Membership Plans (3 plans)
-- ============================================================
insert into membership_plans (id, name, monthly_price_cents, included_services, wash_limit, discount_percent, description) values
  (gen_random_uuid(), 'Silver', 3000, '{"Basic Exterior"}', 4, 5, 'Great for regular commuters. Get 4 Basic Exterior washes per month and 5% off all other services and add-ons.'),
  (gen_random_uuid(), 'Gold', 5000, '{"Standard Wash"}', null, 10, 'Our most popular plan. Unlimited Standard Washes every month plus 10% off detailing and add-ons. Best value for families.'),
  (gen_random_uuid(), 'Platinum', 8000, '{"Premium Full", "Full Interior Detail"}', null, 20, 'The ultimate membership. Unlimited Premium Full washes, one free Full Interior Detail per month, and 20% off everything else. VIP lane access included.');

-- ============================================================
-- Locations (2 in San Jose)
-- ============================================================
insert into locations (id, name, address, phone, hours, is_active) values
  (gen_random_uuid(), 'Crystal Clear - Downtown San Jose', '245 E Santa Clara St, San Jose, CA 95113', '(408) 555-0120',
    '{"mon": "7:00 AM - 8:00 PM", "tue": "7:00 AM - 8:00 PM", "wed": "7:00 AM - 8:00 PM", "thu": "7:00 AM - 8:00 PM", "fri": "7:00 AM - 9:00 PM", "sat": "8:00 AM - 9:00 PM", "sun": "8:00 AM - 6:00 PM"}'::jsonb,
    true),
  (gen_random_uuid(), 'Crystal Clear - Almaden', '1090 Blossom Hill Rd, San Jose, CA 95123', '(408) 555-0145',
    '{"mon": "7:00 AM - 7:00 PM", "tue": "7:00 AM - 7:00 PM", "wed": "7:00 AM - 7:00 PM", "thu": "7:00 AM - 7:00 PM", "fri": "7:00 AM - 8:00 PM", "sat": "8:00 AM - 8:00 PM", "sun": "9:00 AM - 5:00 PM"}'::jsonb,
    true);

-- ============================================================
-- Customers (8 customers with mix of memberships)
-- We need to reference membership_plan IDs, so we use a CTE
-- ============================================================
do $$
declare
  silver_id uuid;
  gold_id uuid;
  platinum_id uuid;
  loc_downtown_id uuid;
  loc_almaden_id uuid;
  cust_maria_id uuid;
  cust_james_id uuid;
  cust_priya_id uuid;
  cust_tom_id uuid;
  cust_lisa_id uuid;
  cust_carlos_id uuid;
  cust_jennifer_id uuid;
  cust_david_id uuid;
  svc_basic_id uuid;
  svc_standard_id uuid;
  svc_premium_id uuid;
  svc_works_id uuid;
  svc_vacuum_id uuid;
  svc_interior_id uuid;
  svc_detail_id uuid;
  svc_ceramic_id uuid;
  svc_wax_id uuid;
  svc_headlight_id uuid;
begin
  -- Fetch membership plan IDs
  select id into silver_id from membership_plans where name = 'Silver';
  select id into gold_id from membership_plans where name = 'Gold';
  select id into platinum_id from membership_plans where name = 'Platinum';

  -- Fetch location IDs
  select id into loc_downtown_id from locations where name like '%Downtown%';
  select id into loc_almaden_id from locations where name like '%Almaden%';

  -- Fetch service IDs
  select id into svc_basic_id from services where name = 'Basic Exterior';
  select id into svc_standard_id from services where name = 'Standard Wash';
  select id into svc_premium_id from services where name = 'Premium Full';
  select id into svc_works_id from services where name = 'The Works';
  select id into svc_vacuum_id from services where name = 'Express Vacuum';
  select id into svc_interior_id from services where name = 'Full Interior Detail';
  select id into svc_detail_id from services where name = 'Complete Detail';
  select id into svc_ceramic_id from services where name = 'Ceramic Coating';
  select id into svc_wax_id from services where name = 'Express Wax';
  select id into svc_headlight_id from services where name = 'Headlight Restoration';

  -- Insert customers
  cust_maria_id := gen_random_uuid();
  cust_james_id := gen_random_uuid();
  cust_priya_id := gen_random_uuid();
  cust_tom_id := gen_random_uuid();
  cust_lisa_id := gen_random_uuid();
  cust_carlos_id := gen_random_uuid();
  cust_jennifer_id := gen_random_uuid();
  cust_david_id := gen_random_uuid();

  insert into customers (id, name, phone, email, membership_plan_id, membership_start, vehicle_info, created_at) values
    (cust_maria_id, 'Maria Gonzalez', '+14085551234', 'maria.gonzalez@email.com', gold_id, '2025-09-15', '2022 White Honda Civic', now() - interval '7 months'),
    (cust_james_id, 'James Chen', '+14085552345', 'james.chen@email.com', platinum_id, '2025-06-01', '2023 Black Tesla Model 3', now() - interval '10 months'),
    (cust_priya_id, 'Priya Patel', '+14085553456', 'priya.patel@email.com', silver_id, '2026-01-10', '2021 Blue Toyota RAV4', now() - interval '3 months'),
    (cust_tom_id, 'Tom Nguyen', '+14085554567', 'tom.nguyen@email.com', null, null, '2020 Red Ford F-150', now() - interval '5 months'),
    (cust_lisa_id, 'Lisa Martinez', '+14085555678', 'lisa.martinez@email.com', gold_id, '2025-11-20', '2024 Silver BMW X3', now() - interval '5 months'),
    (cust_carlos_id, 'Carlos Rivera', '+14085556789', null, null, null, '2019 Gray Chevrolet Malibu', now() - interval '2 months'),
    (cust_jennifer_id, 'Jennifer Kim', '+14085557890', 'jennifer.kim@email.com', platinum_id, '2025-03-01', '2023 Pearl White Lexus RX', now() - interval '13 months'),
    (cust_david_id, 'David Washington', '+14085558901', 'david.w@email.com', null, null, '2022 Blue Subaru Outback', now() - interval '1 month');

  -- ============================================================
  -- Bookings (15 bookings - mix of past and future, various statuses)
  -- ============================================================
  insert into bookings (id, customer_id, service_id, location_id, scheduled_at, status, vehicle_info, notes, created_at) values
    -- Past bookings (completed)
    (gen_random_uuid(), cust_maria_id, svc_standard_id, loc_downtown_id, now() - interval '21 days', 'completed', '2022 White Honda Civic', null, now() - interval '23 days'),
    (gen_random_uuid(), cust_james_id, svc_premium_id, loc_almaden_id, now() - interval '14 days', 'completed', '2023 Black Tesla Model 3', 'Preferred hand dry only', now() - interval '16 days'),
    (gen_random_uuid(), cust_priya_id, svc_basic_id, loc_downtown_id, now() - interval '10 days', 'completed', '2021 Blue Toyota RAV4', null, now() - interval '12 days'),
    (gen_random_uuid(), cust_tom_id, svc_works_id, loc_almaden_id, now() - interval '7 days', 'completed', '2020 Red Ford F-150', 'Truck bed needs extra attention', now() - interval '9 days'),
    (gen_random_uuid(), cust_lisa_id, svc_detail_id, loc_downtown_id, now() - interval '5 days', 'completed', '2024 Silver BMW X3', 'First detail on new vehicle', now() - interval '7 days'),
    (gen_random_uuid(), cust_jennifer_id, svc_ceramic_id, loc_almaden_id, now() - interval '3 days', 'completed', '2023 Pearl White Lexus RX', 'Ceramic coating refresh', now() - interval '5 days'),
    -- Past booking (no-show)
    (gen_random_uuid(), cust_carlos_id, svc_standard_id, loc_downtown_id, now() - interval '4 days', 'no-show', '2019 Gray Chevrolet Malibu', null, now() - interval '6 days'),
    -- Past booking (cancelled)
    (gen_random_uuid(), cust_david_id, svc_premium_id, loc_almaden_id, now() - interval '2 days', 'cancelled', '2022 Blue Subaru Outback', 'Customer called to cancel - rescheduling', now() - interval '4 days'),
    -- Upcoming bookings (confirmed)
    (gen_random_uuid(), cust_maria_id, svc_standard_id, loc_downtown_id, now() + interval '1 day', 'confirmed', '2022 White Honda Civic', null, now() - interval '1 day'),
    (gen_random_uuid(), cust_james_id, svc_interior_id, loc_almaden_id, now() + interval '2 days', 'confirmed', '2023 Black Tesla Model 3', 'Monthly free detail (Platinum)', now()),
    (gen_random_uuid(), cust_tom_id, svc_basic_id, loc_downtown_id, now() + interval '3 days', 'confirmed', '2020 Red Ford F-150', null, now()),
    (gen_random_uuid(), cust_david_id, svc_premium_id, loc_almaden_id, now() + interval '3 days', 'confirmed', '2022 Blue Subaru Outback', 'Rescheduled from last week', now()),
    (gen_random_uuid(), cust_lisa_id, svc_wax_id, loc_downtown_id, now() + interval '5 days', 'confirmed', '2024 Silver BMW X3', 'Add-on after standard wash', now()),
    (gen_random_uuid(), cust_priya_id, svc_basic_id, loc_downtown_id, now() + interval '6 days', 'confirmed', '2021 Blue Toyota RAV4', null, now()),
    (gen_random_uuid(), cust_jennifer_id, svc_headlight_id, loc_almaden_id, now() + interval '7 days', 'confirmed', '2023 Pearl White Lexus RX', 'Headlights getting hazy', now());

  -- ============================================================
  -- Complaints (5 complaints in various states)
  -- ============================================================
  insert into complaints (id, customer_id, booking_id, category, description, status, resolution, created_at) values
    (gen_random_uuid(), cust_tom_id,
      (select id from bookings where customer_id = cust_tom_id and status = 'completed' limit 1),
      'quality', 'There were still water spots on the hood and roof after my wash. I paid for The Works and expected better.', 'resolved', 'Apologized and provided a complimentary re-wash plus free Express Wax. Customer was satisfied with the resolution.', now() - interval '6 days'),
    (gen_random_uuid(), cust_maria_id,
      (select id from bookings where customer_id = cust_maria_id and status = 'completed' limit 1),
      'wait_time', 'I had a 10am appointment but did not get my car back until 11:15am. The wait was way too long for a Standard Wash.', 'investigating', null, now() - interval '20 days'),
    (gen_random_uuid(), cust_carlos_id, null,
      'billing', 'I was charged twice for my last wash. I see two charges of $18 on my credit card statement from March 15.', 'open', null, now() - interval '1 day'),
    (gen_random_uuid(), cust_jennifer_id,
      (select id from bookings where customer_id = cust_jennifer_id and status = 'completed' limit 1),
      'damage', 'I noticed a small scratch on the passenger side door after my ceramic coating appointment. This was not there before.', 'investigating', null, now() - interval '2 days'),
    (gen_random_uuid(), cust_lisa_id,
      (select id from bookings where customer_id = cust_lisa_id and status = 'completed' limit 1),
      'quality', 'The interior of my car still smelled like cleaning chemicals hours after the detail. It gave me a headache.', 'resolved', 'Switched to hypoallergenic cleaning products for this customer. Added a note to their profile. Offered 20% off next visit.', now() - interval '4 days');

end $$;

-- ============================================================
-- Knowledge Docs (30+ documents covering FAQs, policies, services, etc.)
-- Embeddings left NULL - to be populated by the embedding script
-- ============================================================
insert into knowledge_docs (id, title, content, category, embedding) values

-- Company Info
(gen_random_uuid(), 'About Crystal Clear Car Wash',
'Crystal Clear Car Wash has been serving the San Jose community since 2018. We are a locally owned and operated car wash dedicated to providing exceptional quality and customer service. Our team of trained professionals uses eco-friendly products and the latest techniques to keep your vehicle looking its best. We believe every car deserves the crystal clear treatment.',
'company', null),

(gen_random_uuid(), 'Our Mission and Values',
'At Crystal Clear Car Wash, our mission is to deliver a sparkling clean vehicle every time while being environmentally responsible. We use biodegradable soaps, water reclamation systems, and energy-efficient equipment. We value quality, consistency, customer satisfaction, and sustainability. Every team member is trained to treat your vehicle as if it were their own.',
'company', null),

-- Locations and Hours
(gen_random_uuid(), 'Downtown San Jose Location',
'Our Downtown San Jose location is at 245 E Santa Clara St, San Jose, CA 95113. Phone: (408) 555-0120. Hours: Monday-Thursday 7:00 AM to 8:00 PM, Friday 7:00 AM to 9:00 PM, Saturday 8:00 AM to 9:00 PM, Sunday 8:00 AM to 6:00 PM. We are conveniently located near the San Jose Convention Center with easy access from I-280 and I-87. Street parking and a small lot are available.',
'location', null),

(gen_random_uuid(), 'Almaden Location',
'Our Almaden location is at 1090 Blossom Hill Rd, San Jose, CA 95123. Phone: (408) 555-0145. Hours: Monday-Thursday 7:00 AM to 7:00 PM, Friday 7:00 AM to 8:00 PM, Saturday 8:00 AM to 8:00 PM, Sunday 9:00 AM to 5:00 PM. Located in the Almaden Plaza shopping center with plenty of free parking. Easy access from Almaden Expressway.',
'location', null),

-- Service Descriptions
(gen_random_uuid(), 'Basic Exterior Wash',
'Our Basic Exterior wash costs $12 and takes about 15 minutes. It includes a thorough hand wash of the entire exterior, spot-free rinse, and careful hand dry. This is perfect for a quick clean when you are short on time. Available at both locations, no appointment needed for this service.',
'service_info', null),

(gen_random_uuid(), 'Standard Wash',
'The Standard Wash is $18 and takes about 25 minutes. It includes everything in the Basic Exterior plus window cleaning inside and out, tire dressing for a fresh look, and a quick dashboard wipe-down. This is our most popular individual wash and a great everyday option.',
'service_info', null),

(gen_random_uuid(), 'Premium Full Wash',
'The Premium Full wash is $25 and takes about 40 minutes. This is a complete interior and exterior treatment. It includes a full hand wash, thorough vacuuming of seats and floors, interior surface wipe-down, window cleaning, and tire shine. Your car will look and feel great inside and out.',
'service_info', null),

(gen_random_uuid(), 'The Works Package',
'The Works is our top-tier wash package at $45, taking about 60 minutes. It includes everything in the Premium Full plus a hand wax for lasting exterior protection, leather conditioning for seats, and your choice of premium air freshener. This is the ultimate regular maintenance wash.',
'service_info', null),

(gen_random_uuid(), 'Express Vacuum',
'The Express Vacuum service is $15 and takes about 15 minutes. We thoroughly vacuum all seats, floor mats, carpet, and trunk area. This is a quick way to freshen up your interior between full washes. Great for pet owners or families with kids.',
'service_info', null),

(gen_random_uuid(), 'Full Interior Detail',
'Our Full Interior Detail is $55 and takes about 90 minutes. This is a deep clean of every interior surface. It includes steam cleaning, carpet and upholstery shampooing, leather cleaning and conditioning, dashboard and console detailing, vent cleaning, and a full sanitization. Your interior will look and smell like new.',
'service_info', null),

(gen_random_uuid(), 'Complete Detail Service',
'The Complete Detail is $89 and takes about 2.5 hours. This is our most comprehensive service combining a full interior detail with premium exterior treatment. The exterior gets a clay bar treatment to remove contaminants, machine polish to remove light scratches, and a hand wax for protection. This is the best way to restore your vehicle to showroom condition.',
'service_info', null),

(gen_random_uuid(), 'Ceramic Coating Service',
'Our Ceramic Coating service is $150 and takes about 3 hours. We apply a professional-grade ceramic coating that bonds to your paint, providing 6 to 12 months of protection. Benefits include extreme hydrophobic properties, UV protection, chemical resistance, and an incredible deep gloss. We recommend this after a Complete Detail for best results.',
'service_info', null),

(gen_random_uuid(), 'Add-On Services',
'We offer several add-on services that can be combined with any wash. Express Wax ($15, 15 min) adds an extra layer of shine and protection. Tire Shine ($8, 10 min) gives your tires a rich, deep black finish. Air Freshener ($5, 5 min) is a long-lasting premium freshener in your choice of Ocean Breeze, New Car, Vanilla, or Lavender. Headlight Restoration ($45, 45 min) restores cloudy or yellowed headlights to clear.',
'service_info', null),

-- Membership Benefits
(gen_random_uuid(), 'Silver Membership',
'The Silver membership costs $30 per month and includes 4 Basic Exterior washes per month plus 5% off all other services and add-ons. This is great for commuters who want to keep their car clean with regular basic washes. That is a savings of at least $18 per month compared to paying individually. Cancel anytime with 30 days notice.',
'membership', null),

(gen_random_uuid(), 'Gold Membership',
'The Gold membership costs $50 per month and includes unlimited Standard Washes plus 10% off all detailing services and add-ons. This is our most popular plan and is perfect for families or anyone who washes their car frequently. Even two Standard Washes per month makes it worthwhile. The 10% discount on detailing adds up fast. Cancel anytime with 30 days notice.',
'membership', null),

(gen_random_uuid(), 'Platinum Membership',
'The Platinum membership is $80 per month and includes unlimited Premium Full washes, one free Full Interior Detail per month, and 20% off everything else. Platinum members also get VIP lane access so you skip the regular line. This is our best value for car enthusiasts who want their vehicle looking perfect at all times. Cancel anytime with 30 days notice.',
'membership', null),

(gen_random_uuid(), 'Membership Comparison and How to Sign Up',
'We offer three membership tiers: Silver ($30/mo, 4 basic washes, 5% off), Gold ($50/mo, unlimited standard washes, 10% off), and Platinum ($80/mo, unlimited premium washes, 1 free detail, 20% off, VIP lane). All memberships can be used at both locations. You can sign up in person at either location, over the phone, or through our voice agent. Memberships are billed monthly and you can upgrade, downgrade, or cancel anytime with 30 days notice.',
'membership', null),

-- FAQs
(gen_random_uuid(), 'Do I need an appointment?',
'Appointments are not required for basic wash services (Basic Exterior, Standard Wash, Premium Full). However, we recommend appointments for The Works, all detailing services, and Ceramic Coating to ensure availability. Walk-ins are welcome but appointment holders get priority. You can book by calling us, speaking with our voice agent, or visiting either location.',
'faq', null),

(gen_random_uuid(), 'How long does each service take?',
'Service times vary: Basic Exterior takes about 15 minutes, Standard Wash about 25 minutes, Premium Full about 40 minutes, The Works about 60 minutes, Express Vacuum about 15 minutes, Full Interior Detail about 90 minutes, Complete Detail about 2.5 hours, and Ceramic Coating about 3 hours. These are approximate times and may vary slightly depending on vehicle size and condition.',
'faq', null),

(gen_random_uuid(), 'What payment methods do you accept?',
'We accept all major credit and debit cards (Visa, Mastercard, American Express, Discover), Apple Pay, Google Pay, and cash. Membership payments are charged automatically to the card on file. We do not accept personal checks.',
'faq', null),

(gen_random_uuid(), 'Can I wait while my car is being washed?',
'Yes! Both locations have comfortable waiting areas with free Wi-Fi, complimentary coffee and water, and a TV. For longer services like detailing, you are welcome to drop off your vehicle and we will call or text you when it is ready. We also have a few tables and chairs outside if you prefer fresh air.',
'faq', null),

(gen_random_uuid(), 'Do you wash trucks, SUVs, and large vehicles?',
'Absolutely! We wash all types of passenger vehicles including sedans, SUVs, trucks, minivans, and crossovers. There is no extra charge for larger vehicles on our wash services. For detailing services on extra-large vehicles (full-size trucks, large SUVs), there may be a small surcharge of $10-$20 depending on the service. Our team will let you know before starting.',
'faq', null),

-- Policies
(gen_random_uuid(), 'Cancellation and Rescheduling Policy',
'You can cancel or reschedule any appointment up to 2 hours before your scheduled time at no charge. Cancellations with less than 2 hours notice may be subject to a $10 fee. No-shows may be charged 50% of the service price. To cancel or reschedule, call us or speak with our voice agent. Membership holders are never charged cancellation fees.',
'policy', null),

(gen_random_uuid(), 'Satisfaction Guarantee',
'We stand behind our work with a 100% satisfaction guarantee. If you are not happy with any service, bring your vehicle back within 48 hours and we will redo the service at no additional charge. For detailing and ceramic coating services, our guarantee extends to 7 days. If there is an issue, please let us know immediately so we can make it right.',
'policy', null),

(gen_random_uuid(), 'Damage Policy',
'While we take every precaution to protect your vehicle, if you believe your vehicle was damaged during a service, please report it immediately before leaving the premises. We will document the concern with photos and investigate. Pre-existing damage should be noted before service begins. We carry full insurance and will cover any verified damage caused by our team.',
'policy', null),

(gen_random_uuid(), 'Rain Guarantee',
'If it rains within 48 hours of your wash service, bring your vehicle back for a free re-wash (same service level or Basic Exterior, whichever was originally purchased). Just show your receipt or we can look up your visit. This applies to all wash services but not detailing or ceramic coating.',
'policy', null),

-- Promotions
(gen_random_uuid(), 'Current Promotions and Deals',
'Check out our current offers: First-time customers get 20% off any service. Refer a friend and you both get a free Basic Exterior wash. Students and military get 10% off all services with valid ID. Senior citizens (65+) get 10% off every Tuesday. Bundle any wash with an Express Wax and save $5. Book a Complete Detail and get a free Air Freshener.',
'promotion', null),

(gen_random_uuid(), 'Gift Cards',
'Crystal Clear Car Wash gift cards are available in any amount from $25 to $500. They make a great gift for any occasion. Gift cards can be purchased at either location and are valid at both locations. They never expire and there are no fees. Ask about our holiday gift card special: buy a $50 gift card and get a bonus $10 card free (available November through December).',
'promotion', null),

-- Care Tips
(gen_random_uuid(), 'How Often Should You Wash Your Car?',
'We recommend washing your car every 1 to 2 weeks to maintain its appearance and protect the paint. If you park under trees, drive on dusty roads, or live near the coast, you may want to wash more frequently. Bird droppings, tree sap, and bug splatter should be removed as soon as possible to prevent paint damage. Regular washing also helps maintain your vehicle resale value.',
'care_tips', null),

(gen_random_uuid(), 'Tips for Maintaining Your Car Between Washes',
'Between washes, you can keep your car looking fresh with these tips: Use a microfiber cloth to quickly wipe off dust and fingerprints. Keep a small bottle of detail spray and a cloth in your car for quick touch-ups. Shake out floor mats regularly. Avoid parking under trees when possible to prevent sap and bird droppings. If you have a ceramic coating, a quick rinse with water is often all you need.',
'care_tips', null),

(gen_random_uuid(), 'Protecting Your Car Paint in Summer',
'San Jose summers can be harsh on car paint. UV rays, heat, and dust can dull your finish over time. We recommend applying wax or a ceramic coating for protection. Park in shade when possible. Wash off bug splatter and bird droppings quickly as they become harder to remove and more damaging in heat. Consider upgrading to our Premium Full or The Works for built-in protection during summer months.',
'care_tips', null),

(gen_random_uuid(), 'Winter Car Care Tips',
'Even in San Jose, winter brings rain and road grime that can affect your vehicle. After rainy days, a quick wash removes contaminants that can cause water spots. Pay attention to your undercarriage if you have driven through standing water. Our Standard Wash includes tire dressing which helps protect against winter road conditions. Consider a wax treatment before the rainy season starts for extra paint protection.',
'care_tips', null);
