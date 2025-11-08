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
  ];

  static final List<Offer> offers = [
    Offer(
      id: 'o_camera_1',
      itemId: 'i_camera',
      amount: 820,
      fromUser: 'Ayla F.',
      message: 'Can pick up this weekend. Includes case?',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
}
