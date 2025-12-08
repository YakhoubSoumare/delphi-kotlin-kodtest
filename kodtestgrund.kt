package kodTest.Winassist

/*
Testet består i att ta funktionen TestaInköpspriserBtnClick i AktiveraSnittpris.pas och översätta den till Kotlin

Gui delar behöver inte konverteras utan vi tänker att den befintliga funktionen fortfarande ska hantera gui och bara anropa den nya funktionen för att få Antal och LagerRe som svar
Application.processMessages och Screen.Cursor kan du ignorera de berör bara gui applikationen.
Du behöver inte ta hand om Open eller Close av tabeller

Dm är databashantering.  Du får en dummy som funkar i uppgiften
Dm.Lager kan du ignorera vi förutsätter att en lista med LagerPoster skickas in i funktionen

getInkopsPris är en funktion som räknar ut priser via diverse regler.  Du får en dummy som funkar i uppgiften
getInkopsPrisVNetto är en funktion som räknar ut inköpspriser via diverse regler.  Du får en dummy som funkar i uppgiften

L_ är en översättningsFunktion Du får en dummy som funkar i uppgiften

IsFloatString är en intern funktion som gör om en string till en integer.  Den kan du ignorera vi förutsätter att talen redan är doubles

 */

class KodTest {
	fun TestaInkopspriserBtnClick(stock: List<Lager>): Pair<Int,List<String>> {
		//Insert code here :-)
	}

	fun getInkopsPris(brutto: Double, mk: String, rk: String, vg: String, pg: String): Double {
		return brutto
	}

	fun getInkopsPrisVNetto(brutto: Double, mk: String, rk: String, vg: String, pg: String): Double {
		return brutto / 2.0
	}

	fun L_(id: Int, text: String): String {
		return text
	}
}

class DM {
	companion object {
		val lager1 = Lager("123VO", "lgrJA", "123", "VO")
		val lager2 = Lager("456VO", "lgrHEMTAGEN", "456", "VO")
		val artikel1 = Artikel("123VO", "123", "VO", "Artikel 1", "RAB1", "VGR1", "PG1", true, 123.45, 0.0, false, 0.0)
		val artikel2 = Artikel("456VO", "456", "VO", "Artikel 2", "RAB2", "VGR2", "PG2", true, 234.56, 0.0, false, 0.0)
		fun getLager(): List<Lager> {
			return listOf(lager1, lager2)
		}

		fun getArtikel(artikelMk: String): Artikel? {
			return when (artikelMk) {
				"123VO" -> artikel1
				"456VO" -> artikel2
				else -> null
			}
		}
	}
}

data class Lager(
	val artikelMk: String,
	val lgrStatus: String,
	val artikelnr: String,
	val mk: String
)

data class Artikel(
	val artikelMk: String,
	val artikelnr: String,
	val mk: String,
	val benamning1: String,
	val rabattKod: String,
	val varuGrupp: String,
	val prodGrupp: String,
	val fastPris: Boolean,
	val pris: Double,
	val inkop: Double,
	val useNetto: Boolean,
	val vNetto: Double
)