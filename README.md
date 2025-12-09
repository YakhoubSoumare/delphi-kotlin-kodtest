# README

## Översikt

Kotlin-funktionen `TestaInkopspriserBtnClick` är en moderniserad version av Delphi-logiken där GUI- och datalagerkod har tagits bort enligt uppgiften.
Funktionen arbetar nu endast med dataklasser och affärslogik och returnerar `(antal, rader)`.

Projektet använder Gradle samt enhetstester som verifierar delar av funktionen.

---

## Körning

### Bygg och kör tester

```bash
    ./gradlew test
```

### Bygg projektet

```bash
    ./gradlew build
```

Testrapport finns i:

```bash
    build/reports/tests/test/index.html
```

Öpnna den i webläsaren genom att högerklicka på den → "Open in Default Browser"

---

## Logiköversikt (diagram)

```txt
               +----------------------+
               |  Lager-lista (input) |
               +----------+-----------+
                          |
                          v
             +---------------------------+
             |  Filtrera på lgrStatus    |
             | (JA / HEMTAGEN / UTGAENDE)|
             +-----------+---------------+
                         | relevanta
                         v
        +--------------------------------------+
        | Slå upp artikel via DM.getArtikel()  |
        +-----------+--------------------------+
                    | artikel finns / saknas
   +----------------+--------------------+
   |                                     |
   v                                     v
+--------------------+         +------------------------------+
| Artikel hittas     |         | Artikel saknas               |
| - antal++          |         | - typ/kod tomma              |
| - prislogik F/V/B  |         | - benämning "SAKNAS..."      |
+--------------------+         | - taMed = true               |
               |               +------------------------------+
               v
       +-------------------------+
       | taMed == true ?        |
       | → lägg rad i listan    |
       +-----------+-------------+
                   |
                   v
        +----------------------------+
        | Returnera (antal, rader)  |
        +----------------------------+
```

---

## Genomförd modernisering

* Affärslogik behållen (prisregler, typ/kod-bestämning, urval, räkning).
* GUI-kod och datakoppling borttagen (Lines.Add, Caption, Screen.*, FieldByName, Open/Close etc.).
* Dummy-implementationer används för prisfunktioner och datalager enligt uppgiften.

---

## Tester

Tester finns under `src/test/kotlin` och täcker:

* statusfiltrering
* hantering av saknad artikel
* fastprislogik (typ F, kod IS)

Körs via:

```bash
    ./gradlew clean test
```

---

## Förbättringsmöjligheter

* **Renare filtrering**
  Ersätt loop + `continue` med funktionell filtrering:

  ```kotlin
    stock.filter { it.lgrStatus in RELEVANTA_STATUS }
  ```

* **Enum för lagerstatus**
  Minskar behovet av strängjämförelser och felstavningar.

* **Dataklass för radresultat**
  Gör radstrukturen typad i stället för ren stränghantering, t.ex.:

  ```kotlin
    data class RadResultat(...)
  ```

---
