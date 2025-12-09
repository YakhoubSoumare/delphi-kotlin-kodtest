package kodTest.Winassist

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class MissingArticleTest {

    @Test
    fun `hanteringskontroll av artikel saknas`() {
        val lager = Lager(
            artikelMk = "FinnsEj",
            lgrStatus = "lgrJA",
            artikelnr = "999",
            mk = "VO"
        )

        val stock = listOf(lager)

        val kodTest = KodTest()
        val (antal, rader) = kodTest.TestaInkopspriserBtnClick(stock)

        assertEquals(0, antal)  // ingen artikel
        assertEquals(1, rader.size)

        val rad = rader.first()
        assertTrue(rad.contains("SAKNAS I ARTIKELREGISTER"))
        assertTrue(rad.contains("artNr=999"))

    }
}