import '../models/my_item.dart';
import '../models/offer.dart';
import '../models/property.dart';

class MockData {
  MockData._();

  static final List<Property> properties = [
    Property(
      id: 'p_modern',
      title: 'Modern Apartment',
      price: 2400000,
      mortgageEligible: true,
      images: const [
        'https://picsum.photos/seed/p_modern_main/1200/900',
        'https://picsum.photos/seed/p_modern_alt1/1200/900',
        'https://picsum.photos/seed/p_modern_alt2/1200/900',
      ],
      spinFrames: List.generate(
        24,
        (index) => 'https://picsum.photos/seed/p_modern_f${index + 1}/1200/900',
      ),
      address: '88 Hudson Yards',
      city: 'Manhattan, NY',
      area: 165,
      description:
          'Expansive modern living with sun-lit rooms, minimalist design, premium finishes and concierge access.',
      facilities: PropertyFacilities(beds: 3, baths: 2, area: 165, parking: 1, garden: 0),
      tags: const ['modern', 'cityscape', 'new'],
      rating: 4.8,
    ),
    Property(
      id: 'p_lumina',
      title: 'Lumina Apartment',
      price: 1850000,
      mortgageEligible: true,
      images: const [
        'https://picsum.photos/seed/p_lumina_main/1200/900',
        'https://picsum.photos/seed/p_lumina_alt1/1200/900',
        'https://picsum.photos/seed/p_lumina_alt2/1200/900',
      ],
      spinFrames: List.generate(
        24,
        (index) => 'https://picsum.photos/seed/p_lumina_f${index + 1}/1200/900',
      ),
      address: 'Palm View Towers',
      city: 'Dubai Marina',
      area: 140,
      description:
          'Bright ivory interior with full-height glass, waterfront views and flexible open plan.',
      facilities: PropertyFacilities(beds: 2, baths: 2, area: 140, parking: 1, garden: 0),
      tags: const ['ivory', 'waterfront', 'deal_9_brokerage'],
      rating: 4.6,
    ),
    Property(
      id: 'p_city',
      title: 'Cityscape Apartment',
      price: 1290000,
      mortgageEligible: false,
      images: const [
        'https://picsum.photos/seed/p_city_main/1200/900',
        'https://picsum.photos/seed/p_city_alt1/1200/900',
        'https://picsum.photos/seed/p_city_alt2/1200/900',
      ],
      spinFrames: List.generate(
        24,
        (index) => 'https://picsum.photos/seed/p_city_f${index + 1}/1200/900',
      ),
      address: 'Market Street Hub',
      city: 'San Francisco',
      area: 110,
      description:
          'Compact, well-lit apartment near transit hub with panoramic skyline views.',
      facilities: PropertyFacilities(beds: 2, baths: 1, area: 110, parking: 0, garden: 0),
      tags: const ['deal', 'compact', 'skyline'],
      rating: 4.3,
    ),
    Property(
      id: 'p_orange_loft',
      title: 'Noir Skyline Loft',
      price: 3200000,
      mortgageEligible: true,
      images: const [
        'https://picsum.photos/seed/p_orange_loft_main/1200/900',
        'https://picsum.photos/seed/p_orange_loft_alt1/1200/900',
        'https://picsum.photos/seed/p_orange_loft_alt2/1200/900',
      ],
      spinFrames: List.generate(
        24,
        (index) => 'https://picsum.photos/seed/p_orange_loft_f${index + 1}/1200/900',
      ),
      address: 'Skyline Terrace 55',
      city: 'Chicago, IL',
      area: 210,
      description:
          'Double-height noir loft with floating stairs, designer lighting and private skyline terrace.',
      facilities: PropertyFacilities(beds: 3, baths: 3, area: 210, parking: 2, garden: 0),
      tags: const ['modern', 'loft', 'nightlife'],
      rating: 4.9,
    ),
    Property(
      id: 'p_ivory_villa',
      title: 'Ivory Courtyard Villa',
      price: 2750000,
      mortgageEligible: true,
      images: const [
        'https://picsum.photos/seed/p_ivory_villa_main/1200/900',
        'https://picsum.photos/seed/p_ivory_villa_alt1/1200/900',
        'https://picsum.photos/seed/p_ivory_villa_alt2/1200/900',
      ],
      spinFrames: List.generate(
        24,
        (index) => 'https://picsum.photos/seed/p_ivory_villa_f${index + 1}/1200/900',
      ),
      address: 'Golden Sands Residences',
      city: 'Abu Dhabi',
      area: 260,
      description:
          'Ivory stone villa wrapped around a tranquil courtyard with water features and lush greenery.',
      facilities: PropertyFacilities(beds: 4, baths: 4, area: 260, parking: 2, garden: 1),
      tags: const ['ivory', 'villa', 'garden'],
      rating: 4.7,
    ),
    Property(
      id: 'p_coastal',
      title: 'Sunlit Coastal Retreat',
      price: 2150000,
      mortgageEligible: false,
      images: const [
        'https://picsum.photos/seed/p_coastal_main/1200/900',
        'https://picsum.photos/seed/p_coastal_alt1/1200/900',
        'https://picsum.photos/seed/p_coastal_alt2/1200/900',
      ],
      spinFrames: List.generate(
        24,
        (index) => 'https://picsum.photos/seed/p_coastal_f${index + 1}/1200/900',
      ),
      address: 'Azure Bay Promenade',
      city: 'Lisbon',
      area: 180,
      description:
          'Floor-to-ceiling glass with uninterrupted ocean views, ivory palette and organic textures.',
      facilities: PropertyFacilities(beds: 3, baths: 2, area: 180, parking: 1, garden: 1),
      tags: const ['ivory', 'waterfront', 'retreat'],
      rating: 4.5,
    ),
    Property(
      id: 'p_garden_tower',
      title: 'Garden Tower Duplex',
      price: 1980000,
      mortgageEligible: true,
      images: const [
        'https://picsum.photos/seed/p_garden_tower_main/1200/900',
        'https://picsum.photos/seed/p_garden_tower_alt1/1200/900',
        'https://picsum.photos/seed/p_garden_tower_alt2/1200/900',
      ],
      spinFrames: List.generate(
        24,
        (index) => 'https://picsum.photos/seed/p_garden_tower_f${index + 1}/1200/900',
      ),
      address: 'Verdant Axis 21',
      city: 'Singapore',
      area: 190,
      description:
          'Biophilic duplex with double terraces, indoor planters and gradient lighting bridging noir and ivory palettes.',
      facilities: PropertyFacilities(beds: 3, baths: 3, area: 190, parking: 1, garden: 1),
      tags: const ['modern', 'garden', 'smart_home'],
      rating: 4.8,
    ),
  ];

  static final List<MyItem> myItems = [
    MyItem(
      id: 'i_camera',
      title: 'Mirrorless Camera XT-4',
      photos: const [
        'https://picsum.photos/seed/i_camera_1/800/600',
        'https://picsum.photos/seed/i_camera_2/800/600',
      ],
      specs: MyItemSpecs(
        condition: 'Good',
        brand: 'Fujifilm',
        year: 2022,
        notes: 'Minor scuffs, includes extra battery',
      ),
      forSale: false,
      wantedPrice: 900,
      tips: const ['Clean sensor routinely', 'Check shutter count', 'Update firmware'],
      status: 'waiting_offers',
    ),
    MyItem(
      id: 'i_smart_sofa',
      title: 'Smart Lounger Sofa',
      photos: const [
        'https://picsum.photos/seed/i_sofa_1/800/600',
        'https://picsum.photos/seed/i_sofa_2/800/600',
      ],
      specs: MyItemSpecs(
        condition: 'Excellent',
        brand: 'NeoRest',
        year: 2021,
        notes: 'Built-in warming, speakers and ambient lighting',
      ),
      forSale: true,
      wantedPrice: 520,
      tips: const ['Keep fabric protector active', 'Run self-clean cycle monthly'],
      status: 'listed',
    ),
    MyItem(
      id: 'i_drone',
      title: '4K Mapping Drone',
      photos: const [
        'https://picsum.photos/seed/i_drone_1/800/600',
        'https://picsum.photos/seed/i_drone_2/800/600',
      ],
      specs: MyItemSpecs(
        condition: 'Like new',
        brand: 'AeroViz',
        year: 2023,
        notes: 'Includes ND filters set and carrying case',
      ),
      forSale: false,
      wantedPrice: 1100,
      tips: const ['Update firmware before each flight', 'Calibrate gimbal outdoors'],
      status: 'waiting_offers',
    ),
  ];

  static final List<Offer> offers = [
    Offer(
      id: 'o_camera_1',
      itemId: 'i_camera',
      amount: 820,
      fromUser: 'Ayla F.',
      message: 'Can pick up this weekend. Includes case?',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: OfferStatus.pending,
    ),
    Offer(
      id: 'o_camera_2',
      itemId: 'i_camera',
      amount: 880,
      fromUser: 'Yuri K.',
      message: 'Happy to match your asking price if available tomorrow morning.',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      status: OfferStatus.accepted,
      counterAmount: 880,
      responseNote: 'Confirmed for Saturday handoff.',
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Offer(
      id: 'o_sofa_1',
      itemId: 'i_smart_sofa',
      amount: 450,
      fromUser: 'Noah S.',
      message: 'Looking to furnish a noir loft, can pick up tonight.',
      createdAt: DateTime.now().subtract(const Duration(hours: 11)),
      status: OfferStatus.countered,
      counterAmount: 500,
      responseNote: 'Holding at $500 to cover detailing.',
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Offer(
      id: 'o_drone_1',
      itemId: 'i_drone',
      amount: 650,
      fromUser: 'Mira P.',
      message: 'Need for weekend shoot, would you consider renting?',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: OfferStatus.declined,
      responseNote: 'Keeping it reserved for personal projects.',
      updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    ),
  ];
}
