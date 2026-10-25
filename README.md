# 3rd Party Application Packaging

Üç yaygın kurumsal uygulama için **sessiz kurulum, sessiz kaldırma, algılama (detection), gereksinim kontrolü (requirement) ve uç senaryo analizi** çalışması. Scriptler, MECM (SCCM) ve Microsoft Intune gibi dağıtım araçlarında kullanılabilecek şekilde **çıkış kodu (exit code) tabanlı** hazırlanmıştır.

## Kapsanan Uygulamalar

| Uygulama | Installer Tipi | Mimari | Sürüm | Kurulum Davranışı |
|---|---|---|---|---|
| Google Chrome Enterprise | MSI | x64 | 149.0.7827.201 | Per-Machine |
| Mozilla Firefox ESR (tr) | EXE (NSIS) | x86 (32-bit) | 140.12.0 ESR | Per-Machine |
| 7-Zip | MSI (dijital imzasız) | x64 | 26.02 | Per-Machine |

## Her Uygulama İçin Neler Var?

- **Kaynak ve doğrulama:** resmi indirme bağlantısı, SHA256, imza bilgisi, lisans
- **Installer profili:** installer tipi ve tespit yöntemi, per-machine / per-user, yeniden başlatma davranışı, ProductCode / UpgradeCode
- **Install.ps1 / Uninstall.ps1:** sessiz kurulum ve kaldırma, log üretimi, çıkış kodu yönetimi
- **Detect.ps1:** dosya tabanlı algılama (`exit 0` = yüklü, `exit 1` = yüklü değil), alternatif olarak MSI ProductCode ve Registry yöntemleri
- **Requirement.ps1:** mimari, işletim sistemi build numarası, boş disk, RAM ve bekleyen yeniden başlatma kontrolleri
- **Uç senaryo analizi:** yükseltme (upgrade), x86/x64 birlikte bulunması, pending reboot, internetsiz kurulum, açık kullanıcı oturumu, standart kullanıcı yetkisi, UAC / AppLocker
- **Test notları:** doğrulanan ve doğrulanamayan senaryolar

Ayrıntılı açıklamalar için: [`Docs/Uygulama_Paketleme_Dokumantasyonu.pdf`](Docs/Uygulama_Paketleme_Dokumantasyonu.pdf)

## Klasör Yapısı

```
3rd-party-app-packaging/
├── README.md
├── .gitignore
├── Chrome/
│   ├── Install.ps1
│   ├── Uninstall.ps1
│   ├── Detect.ps1
│   └── Requirement.ps1
├── Firefox-ESR/
│   ├── Install.ps1
│   ├── Uninstall.ps1
│   ├── Detect.ps1
│   └── Requirement.ps1
├── 7-Zip/
│   ├── Install.ps1
│   ├── Uninstall.ps1
│   ├── Detect.ps1
│   └── Requirement.ps1
└── Docs/
    └── Uygulama_Paketleme_Dokumantasyonu.pdf
```

## Kurulum Dosyaları ve Bütünlük Doğrulama

Installer dosyaları (`.msi`, `.exe`) **repoya eklenmemiştir**. Resmi kaynaktan indirip aşağıdaki SHA256 değeriyle doğrulayın, ardından ilgili uygulamanın klasörüne scriptlerin yanına koyun.

| Uygulama | Dosya Adı | Resmi Kaynak | SHA256 |
|---|---|---|---|
| Google Chrome Enterprise (x64) | `GoogleChromeStandaloneEnterprise64.msi` | [Chrome Enterprise indirme](https://support.google.com/chrome/a/answer/7650032?hl=tr) | `33C16E1B339176B33DA62FC97EA915F74DDC2516C0BE4F83F2FAD4B5AE1F71CB` |
| Mozilla Firefox ESR 140.12.0 (x86, tr) | `Firefox Setup 140.12.0esr.exe` | [Firefox ESR indirme](https://www.firefox.com/tr/download/all/desktopesr/win/tr/) | `EFB8554562062771E281ACA67F24A8765414EFDC684D878E3A6A341457FD8F67` |
| 7-Zip 26.02 (x64 MSI) | `7z2602-x64.msi` | [7-zip.org](https://www.7-zip.org/download.html) | `DB407A4F6D4999E5C7BC00CE8A882BE94717B56E7FA68140FE3F12605D91643E` |

```powershell
# Hash doğrulama
Get-FileHash .\7z2602-x64.msi -Algorithm SHA256

# İmza kontrolü (Chrome: Google LLC, Firefox: Mozilla Corporation; 7-Zip MSI imzasızdır)
Get-AuthenticodeSignature .\GoogleChromeStandaloneEnterprise64.msi
```

> 7-Zip MSI paketi dijital olarak imzalı değildir (`NotSigned`). Bu nedenle paketin bütünlüğü yalnızca SHA256 karşılaştırmasıyla doğrulanır.

## Hızlı Başlangıç (Kendi Bilgisayarında Deneme)

> Denemeyi gerçek bilgisayarınızda değil, **Windows 10/11 sanal makinede** (VMware, VirtualBox, Hyper-V) yapmanızı ve öncesinde snapshot almanızı öneririm.

1. Repoyu indirin: **Code → Download ZIP**, ardından zip'i açın.
2. Denemek istediğiniz uygulamanın installer'ını yukarıdaki tablodaki resmi bağlantıdan indirin.
3. SHA256 değerini doğrulayın (`Get-FileHash`). Değer tablodakiyle aynı olmalıdır.
4. Installer'ı ilgili uygulamanın klasörüne, scriptlerin yanına koyun (örn. `Chrome\GoogleChromeStandaloneEnterprise64.msi`). Dosya adı tablodaki ile birebir aynı olmalıdır.
5. **PowerShell'i yönetici olarak** açın ve internetten indirilen scriptlerin engellenmemesi için şunu çalıştırın:

```powershell
Get-ChildItem -Recurse -Filter *.ps1 | Unblock-File
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

6. Uygulama klasörüne girip scriptleri şu sırayla çalıştırın. Her birinin çıkış kodunu `$LASTEXITCODE` ile görebilirsiniz:

```powershell
cd .\Chrome

.\Requirement.ps1; $LASTEXITCODE   # 0 = cihaz uygun
.\Install.ps1;     $LASTEXITCODE   # 0 = kurulum başarılı
.\Detect.ps1;      $LASTEXITCODE   # 0 = yüklü
.\Uninstall.ps1;   $LASTEXITCODE   # 0 = kaldırıldı
.\Detect.ps1;      $LASTEXITCODE   # 1 = artık yüklü değil
```

7. Kurulum ve kaldırma logları aynı klasörde `Logs` altında oluşur (MSI paketlerinde ayrıntılı `msiexec` logu, Firefox'ta özet log).

## Kullanım

Yönetici (elevated) PowerShell oturumunda ya da dağıtım aracı üzerinden SYSTEM bağlamında, installer dosyası scriptlerin yanındayken çalıştırın:

```powershell
cd .\Chrome
.\Requirement.ps1   # Cihaz uygun mu?        (0 = uygun, 1 = uygun değil)
.\Install.ps1       # Sessiz kurulum         (log: .\Logs\Chrome_Install.log)
.\Detect.ps1        # Kurulu mu?             (0 = yüklü, 1 = yüklü değil)
.\Uninstall.ps1     # Sessiz kaldırma        (log: .\Logs\Chrome_Uninstall.log)
```

Scriptler `.\Logs` klasörünü gerekirse kendisi oluşturur.

### MECM / Intune için örnek komutlar

| Alan | Komut / Değer |
|---|---|
| Install command | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1` |
| Uninstall command | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Uninstall.ps1` |
| Detection rule | Özel script olarak `Detect.ps1` (veya dosya / MSI ProductCode kuralı) |
| Requirement rule | Özel script olarak `Requirement.ps1` |
| Çalışma bağlamı | System |

### Çıkış Kodları

| Script | Kod | Anlamı |
|---|---|---|
| Install | `0` | Başarılı |
| Install | `1603`, `1618`, `1619` | MSI genel hata / başka kurulum sürüyor / paket açılamadı |
| Install (7-Zip) | `1641`, `3010` | Yeniden başlatma başlatıldı / yeniden başlatma gerekiyor |
| Uninstall (MSI) | `0` | Başarılı |
| Uninstall (MSI) | `1605` | Ürün zaten kurulu değil (başarılı kabul edilir) |
| Detect | `0` / `1` | Yüklü / yüklü değil |
| Requirement | `0` / `1` | Uygun / uygun değil |

## Öne Çıkan Teknik Noktalar

- **Installer tipi tespiti:** Firefox EXE'sinin NSIS tabanlı olduğu 7-Zip ile içeriğine bakılarak (`$PLUGINSDIR` klasörü) belirlenmiş, sessiz kurulum anahtarıyla doğrulanmıştır. EXE paketlerde yerleşik log olmadığı için PowerShell ile log mekanizması eklenmiştir.
- **32-bit uygulama, 64-bit işletim sistemi:** Firefox x86 paketi `Program Files (x86)` altına kurulur ve Registry'de `Wow6432Node` altına yazılır. Algılama ve kaldırma scriptleri bu yola göre hazırlanmıştır.
- **ProductCode sürüme özeldir:** Chrome ve 7-Zip MSI'larında ProductCode her sürümde değişebilir, UpgradeCode sabittir. Bu yüzden sürümden bağımsız algılama için dosya tabanlı yöntem birincil seçilmiş, kaldırma scriptleri ProductCode'u Registry'den dinamik bulmuştur.
- **Standart dışı UninstallString:** 7-Zip'in Registry'deki `UninstallString` değeri `/I` (Install/Modify) içerir. Sessiz kaldırma için bu `/x` (Uninstall) olarak kullanılmıştır.
- **İmzasız MSI:** 7-Zip paketi imzasız olduğundan, kaynak ve SHA256 doğrulaması rapora ve README'ye işlenmiştir.
- **Kullanıcı verisi korunur:** Kaldırma işlemleri yalnızca uygulamayı siler; profil, yer imi ve ayarlar kullanıcı alanında kalır.

## Test Ortamı ve Sınırlamalar

- Windows 11 Pro 23H2 (Build 22631), x64
- VMware Workstation Pro 17 (laboratuvar ortamı)
- PowerShell 5.1, Orca MSI Editor, Registry Editor

Laboratuvar ortamında Active Directory etki alanı ve AppLocker / WDAC politikası bulunmadığından, bu politikalara bağlı senaryolar canlı test edilememiş, teorik olarak analiz edilmiştir (dokümantasyonda ilgili yerlerde belirtilmiştir). Üretim ortamında kullanmadan önce kendi ortamınızda doğrulayın.

## Notlar

- Bu çalışma eğitim ve portföy amaçlıdır.
- Chrome, Firefox ve 7-Zip kendi sahiplerinin ürünleridir; installer dosyaları bu repoda dağıtılmamaktadır.
- Dokümantasyonun hazırlanmasında AI araçlarından (ChatGPT, Gemini) destek alınmıştır.

## Hazırlayan

**İkra Nur Altun**
