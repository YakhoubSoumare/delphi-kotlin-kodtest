package kodTest.Winassist

import kotlin.test.Test // testmetod
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class StatusFilterTest {
    // Testfall
    @Test // Kör detta som en enhetstest
    fun `ignorera lager med irrelevant status`() {

        // Test setup med en faktisk och en påhittad
        val relevantLager = Lager(
            artikelMk = "123VO",   // FINNS i DM.getArtikel
            lgrStatus = "lgrJA",   // ska tas med
            artikelnr = "123",
            mk = "VO"
        )

        val irrelevantLager = Lager(
            artikelMk = "dummy",
            lgrStatus = "ignored",   // bör ignoreras
            artikelnr = "000",
            mk = "ignore-101"
        )

        val stock = listOf(relevantLager, irrelevantLager)

        // för att köra koden visa testa
        val kodTest = KodTest()
        val (antal, rader) = kodTest.TestaInkopspriserBtnClick(stock)


        // Assert: endast ett antal och en enda rad och dubbelkolla rätt värde av MK i string
        assertEquals(1, antal)
        assertEquals(1, rader.size)

        val rad = rader.first()
        assertTrue(rad.contains("VO"))
    }
}