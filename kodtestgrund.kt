package kodTest.Winassist

/*
Testet best�r i att ta funktionen TestaInk�pspriserBtnClick i AktiveraSnittpris.pas och �vers�tta den till Kotlin

Gui delar beh�ver inte konverteras utan vi t�nker att den befintliga funktionen fortfarande ska hantera gui och bara anropa den nya funktionen f�r att f� Antal och LagerRe som svar
Application.processMessages och Screen.Cursor kan du ignorera de ber�r bara gui applikationen.
Du beh�ver inte ta hand om Open eller Close av tabeller

Dm �r databashantering.  Du f�r en dummy som funkar i uppgiften
Dm.Lager kan du ignorera vi f�ruts�tter att en lista med LagerPoster skickas in i funktionen

getInkopsPris �r en funktion som r�knar ut priser via diverse regler.  Du f�r en dummy som funkar i uppgiften
getInkopsPrisVNetto �r en funktion som r�knar ut ink�pspriser via diverse regler.  Du f�r en dummy som funkar i uppgiften

L_ �r en �vers�ttningsFunktion Du f�r en dummy som funkar i uppgiften

IsFloatString �r en intern funktion som g�r om en string till en integer.  Den kan du ignorera vi f�ruts�tter att talen redan �r doubles

 */

class KodTest { // vår nya huvudklass
	fun TestaInkopspriserBtnClick(stock: List<Lager>): Pair<Int,List<String>> {
		var antal : Int = 0;
		val rader : MutableList<String> = mutableListOf()

		for (lager in stock) {

			val status = lager.lgrStatus

			val relevant : Boolean = 
				status == "lgrJA" || 
				status == "lgrHEMTAGEN" || 
				status == "lgrUTGAENDE"

			// 1) filtrera status
			if(!relevant){
				continue
			}

			// 2) slå upp artikel
			val artikel : Artikel? = DM.getArtikel(lager.artikelMk)

			// 3) deklarera variabler
			var artNr: String
			var typ: String = ""
			var kod: String = ""
			var mk: String
			var rk: String
			var vg: String
			var pg: String
			var benamning: String
			var brutto: Double = 0.0
			var netto: Double = 0.0
			var taMed: Boolean = false

			// 4) fall: artikel finns
			if (artikel != null) { // hämtar värden
				antal++
				artNr = artikel.artikelnr
				mk = artikel.mk
				benamning = artikel.benamning1
				rk = artikel.rabattKod
				vg = artikel.varuGrupp
				pg = artikel.prodGrupp

			} else { // sätter värden
				// artikel saknas
				artNr = lager.artikelnr
				mk = lager.mk
				benamning = "SAKNAS I ARTIKELREGISTER"
				typ = ""
				kod = ""
				rk = ""
				brutto = 0.0
				netto = 0.0
				taMed = true
			}

			if (taMed) {
				val rad = "artNr=$artNr; mk=$mk; benamning=$benamning"
				rader.add(rad)
			}

		}

		return(antal, rader)
	}

	fun getInkopsPris(brutto: Double, mk: String, rk: String, vg: String, pg: String): Double { // Dummy utan beräkning
		return brutto
	}

	fun getInkopsPrisVNetto(brutto: Double, mk: String, rk: String, vg: String, pg: String): Double { // Dummy utan beräkning
		return brutto / 2.0
	}

	fun L_(id: Int, text: String): String { // Dummy utan språkbyte
		return text
	}
	
}

class DM {
	companion object { // ungefär static. tillhör klassen och ej instans av klass
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

data class Lager( // record motsvarande DM.Lager
	val artikelMk: String,	// möjligtvis artikelns unika ID
	val lgrStatus: String,
	val artikelnr: String,
	val mk: String
)

data class Artikel( // record motsvarande DM.Artiklar
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