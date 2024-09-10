import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gizlilik Politikası'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''Gizlilik Politikası

ReadSwap uygulaması olarak, kullanıcılarımızın gizliliğine önem veriyoruz. Bu gizlilik politikası, uygulamamız aracılığıyla topladığımız kişisel bilgilerin nasıl kullanıldığını, saklandığını ve korunduğunu açıklamaktadır.

Toplanan Bilgiler
Uygulamamızda kullanıcılarımızdan aşağıdaki bilgileri topluyoruz:
- İsim: Kullanıcıların adlarını kaydederiz.
- Telefon Numarası: Kullanıcılarla iletişim kurmak amacıyla telefon numarası bilgilerini toplarız.
- E-posta Adresi: Kullanıcılara hizmetlerimizle ilgili bilgi vermek ve hesap doğrulama işlemlerini gerçekleştirmek için e-posta adresini toplarız.
- Resim: Kullanıcılar profil resimlerini yükleyebilirler.
- Adres Bilgileri: Siparişlerin teslimatı için kullanıcıların adres bilgilerini toplarız.

Bilgilerin Kullanımı
Topladığımız bilgiler aşağıdaki amaçlarla kullanılabilir:
- Kullanıcı hesaplarını yönetmek ve doğrulamak.
- Siparişlerin işlenmesi ve teslimat süreçlerini yürütmek.
- Kullanıcılara uygulamayla ilgili bildirimler göndermek.
- Müşteri desteği sağlamak ve kullanıcıların sorularını yanıtlamak.

Bilgilerin Paylaşımı
Kullanıcı bilgileriniz üçüncü taraflarla paylaşılmayacaktır, ancak yasal gereklilikler veya kullanıcı izni gibi durumlar dışında paylaşım yapılmayacaktır.

Bilgilerin Saklanması ve Güvenliği
Kullanıcı bilgilerinin güvenliği bizim için önemlidir. Topladığımız bilgileri güvenli sunucularda saklıyoruz ve yetkisiz erişime karşı çeşitli güvenlik önlemleri alıyoruz.

Kullanıcı Hakları
Kullanıcılar, kişisel bilgilerinin silinmesini veya güncellenmesini talep edebilirler. Bu taleplerinizi uygulama içerisinden veya destek ekibimize başvurarak iletebilirsiniz.

Gizlilik Politikası Değişiklikleri
Bu gizlilik politikası zaman zaman güncellenebilir. Politika değişikliklerini uygulama üzerinden kullanıcılarımıza bildireceğiz.

İletişim
Gizlilik politikamız hakkında sorularınız varsa, lütfen bizimle iletişime geçin: [ReadSwap iletişim bilgileri].
''',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
