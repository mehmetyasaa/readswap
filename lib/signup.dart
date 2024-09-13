import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readswap/BookCategorySelectionPage.dart';
import 'package:readswap/TabView.dart';
import 'package:readswap/home_page.dart';
import 'package:readswap/firebase/auth.dart';
import 'package:readswap/loginpage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _controllerDisplayName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();

  String? errorMessage = "";
  double radius = 40;
  double fontSize = 15;

  bool isChecked = false; // Checkbox durumunu takip etmek için
  bool isButtonEnabled = false; // Buton durumunu takip etmek için

  Future<void> createUser(BuildContext context) async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
        username: _controllerDisplayName.text,
        phone: _controllerPhone.text,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CategorySelectionPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  void _toggleCheckbox(bool? value) {
    setState(() {
      isChecked = value ?? false;
      isButtonEnabled = isChecked; // Checkbox seçili ise butonu aktif et
    });
  }

  void _showKVKKDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("KVKK Metni"),
          content: SingleChildScrollView(
            child: Text(
              '''
                KİŞİSEL VERİLERİN KORUNMASI VE GİZLİLİK POLİTİKASI
1. Giriş
ReadSwap platformu ("readswap") olarak, kullanıcılarımızın kişisel verilerinin korunmasına büyük önem vermekteyiz. Bu gizlilik politikası, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") ve ilgili yasal düzenlemeler kapsamında, kişisel verilerinizin nasıl toplandığını, kullanıldığını ve korunduğunu açıklamaktadır. Platformumuz üzerinden sunulan hizmetler sırasında kişisel verilerinizi işleyebiliriz ve bu metinde bununla ilgili haklarınızı bilgilendirme amacıyla açıklamaktayız.
2. Kişisel Verilerin Toplanması
Platformumuzu kullanmanız esnasında aşağıdaki kişisel verileri toplayabiliriz:
•	Kimlik Bilgileri: Ad, soyad,
•	İletişim Bilgileri: E-posta adresi, telefon numarası, adres bilgileri,
•	Hesap Bilgileri: Kullanıcı adı, şifre,
•	İşlem Bilgileri: Platform üzerinde gerçekleştirdiğiniz işlem geçmişi, ilan fotoğrafları,
•	Diğer Bilgiler: Kullanıcıların tercihlerine dayalı işlem bilgileri ve diğer iletişimler.
Bu kişisel veriler, doğrudan sizlerden, Platform’a üye olmanız ve hizmetlerimizi kullanmanız sırasında veya çerezler (cookies) aracılığıyla toplanmaktadır.
3. Kişisel Verilerin İşlenme Amaçları
Kişisel verileriniz aşağıdaki amaçlarla işlenmektedir:
•	Kullanıcı Doğrulaması ve Hesap Oluşturulması: Uygulamamıza giriş yapabilmeniz ve hesabınızı yönetebilmeniz için kimlik bilgilerinizi kullanıyoruz.
•	İşlemlerin Güvenli Yürütülmesi: Satış, alışveriş ve takas işlemlerinin sağlıklı bir şekilde yürütülmesi, size daha iyi bir hizmet sunabilmek için verilerinizi işliyoruz.
•	İletişim: Platform ile ilgili gelişmelerden haberdar olmanız ve destek hizmetlerine erişiminizi sağlamak için iletişim bilgilerinizi kullanıyoruz.
•	Güvenlik ve Yasal Yükümlülükler: Kişisel verileriniz, kanuni gereklilikler ve güvenlik amacıyla, hukuki sorumluluklarımızı yerine getirmek üzere işlenebilir.
4. Kişisel Verilerin Toplanma Yöntemleri
Kişisel verileriniz, şu yöntemlerle toplanmaktadır:
•	Platforma üye olurken sağladığınız bilgiler,
•	Platform üzerinden gerçekleştirilen işlemler (örn. kitap alışverişi ve takası için eklediğiniz ilan fotoğrafları),
•	İletişim formlarını doldururken veya destek birimi ile yaptığınız yazışmalar,
•	Çerezler (cookies) aracılığıyla dijital etkileşimleriniz.
5. Kişisel Verilerin Saklanması ve Güvenliği
Toplanan kişisel verileriniz, Firebase gibi güvenli veri saklama altyapılarında muhafaza edilmektedir. Kişisel verilerin güvenliği için tüm teknik ve idari tedbirler alınmaktadır. Verileriniz, yetkisiz erişim, kaybolma, değiştirilme, ifşa edilme ve kötüye kullanım gibi risklere karşı korunmaktadır.
Kişisel verileriniz, Platform üzerindeki üyeliğiniz devam ettiği sürece veya yasal gereklilikler doğrultusunda belirli süreler boyunca saklanabilir. Mevcut planda, veriler süresiz olarak saklanacaktır.
6. Kişisel Verilerin Paylaşımı
Kişisel verileriniz üçüncü taraflarla paylaşılmamaktadır. Tüm veriler yalnızca Firebase altyapısında saklanmakta olup, Platform dışındaki üçüncü taraf hizmet sağlayıcılarla herhangi bir paylaşım söz konusu değildir. Ancak, yasal yükümlülükler doğrultusunda kişisel verileriniz ilgili kamu kurum ve kuruluşlarına paylaşılabilir.
7. Kişisel Verilerin Güncellenmesi ve Silinmesi
Kullanıcılar, hesaplarına giriş yaparak kişisel bilgilerini güncelleyebilirler. Kişisel verilerin silinmesi için kullanıcıların destek ekibimizle iletişime geçmeleri gerekmektedir. Verilerin silinmesi talebi alındığında, ilgili talepler yasal gereklilikler çerçevesinde değerlendirilip işleme alınacaktır. Yasal bir zorunluluk yoksa verileriniz tamamen silinir.
8. Kullanıcı Hakları
KVKK kapsamında kullanıcılarımızın sahip olduğu haklar şunlardır:
•	Kişisel verilerinin işlenip işlenmediğini öğrenme,
•	Kişisel verileri işlenmişse buna ilişkin bilgi talep etme,
•	Kişisel verilerin işlenme amacını öğrenme ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme,
•	Yurt içinde veya yurt dışında kişisel verilerin aktarıldığı üçüncü kişileri bilme,
•	Kişisel verilerin eksik veya yanlış işlenmiş olması hâlinde bunların düzeltilmesini isteme,
•	İlgili mevzuat çerçevesinde kişisel verilerin silinmesini veya yok edilmesini isteme,
•	Kişisel verilerin düzeltilmesi veya silinmesi halinde, bu işlemlerin kişisel verilerin aktarıldığı üçüncü kişilere bildirilmesini isteme,
•	İşlenen verilerin münhasıran otomatik sistemler aracılığıyla analiz edilmesi suretiyle aleyhinize bir sonucun ortaya çıkmasına itiraz etme,
•	Kişisel verilerin kanuna aykırı olarak işlenmesi sebebiyle zarara uğramanız halinde zararınızın giderilmesini talep etme.
Yukarıda sayılan haklarınızı kullanmak için bizimle [İletişim Bilgileri] üzerinden iletişime geçebilirsiniz.
9. Çerezler (Cookies)
Platformumuzda kullanıcı deneyimini iyileştirmek ve performansı artırmak için çerezler kullanılmaktadır. Çerezler, web tarayıcınız aracılığıyla cihazınıza yerleştirilen ve bazı bilgileri depolayan küçük dosyalardır. Çerezler, kimlik doğrulama, tercihlerinizin hatırlanması ve istatistiksel analizler gibi amaçlarla kullanılmaktadır. Çerez kullanımı ile ilgili detaylı bilgiyi [Çerez Politikası] üzerinden öğrenebilirsiniz.
10. Politika Değişiklikleri
Bu gizlilik politikasında zaman zaman değişiklikler yapabiliriz. Politika değişiklikleri yapıldığında, kullanıcılarımızı bilgilendirecek ve yeni politikayı Platform üzerinde yayınlayacağız. Politika değişikliklerinden haberdar olmak için düzenli olarak bu sayfayı ziyaret etmenizi öneririz.
________________________________________
Sonuç
Veri güvenliği ve gizliliği bizim için önemlidir. Kişisel verilerinizi dikkatli bir şekilde topluyor, işliyor ve koruyoruz. Sorularınız ya da talepleriniz için tubitakcide37@gmail.com üzerinden bizimle iletişime geçebilirsiniz.


              ''',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
              },
              child: Text("Kapat"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 70),
                child: Text(
                  'ReadSwap',
                  style: TextStyle(
                    color: Color(0xFF529471),
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  height: 30,
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/download.png',
                        height: 40,
                        width: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Center(
                          child: Text(
                            'Apple ID ile Giriş Yap',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: fontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: BorderSide(
                    color: const Color.fromARGB(255, 211, 211, 211),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 211, 211, 211),
                    width: 1.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  height: 30,
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/fbLogo.png',
                        height: 40,
                        width: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Center(
                          child: Text(
                            'Facebook ile Giriş Yap',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 211, 211, 211),
                    width: 1.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  height: 30,
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/googleLogo.png',
                        height: 40,
                        width: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Text(
                          'Google ile Giriş Yap',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _controllerDisplayName,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      prefixIcon: Icon(Icons.person, color: Color(0xFF529471)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _controllerEmail,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      prefixIcon: Icon(Icons.email, color: Color(0xFF529471)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _controllerPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      prefixIcon:
                          const Icon(Icons.lock, color: Color(0xFF529471)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLength: 11,
                    controller: _controllerPhone,
                    decoration: InputDecoration(
                      labelText: 'Telefon',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      prefixIcon:
                          const Icon(Icons.phone, color: Color(0xFF529471)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // KVKK Checkbox ve metin butonu
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: _toggleCheckbox,
                      ),
                      GestureDetector(
                        onTap: () {
                          _showKVKKDialog(
                              context); // KVKK metni dialogunu göster
                        },
                        child: const Text(
                          "KVKK metnini okudum ve onaylıyorum",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Kaydol butonu
                  ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () async {
                            await createUser(context);
                          }
                        : null, // Eğer checkbox seçilmezse buton disable
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF529471),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 211, 211, 211),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: SizedBox(
                        height: 30,
                        width: 300,
                        child: Center(
                          child: Text(
                            'Kaydol',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginPagee(),
                              ),
                            );
                          },
                          child: Text("Giriş Yap"))
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
