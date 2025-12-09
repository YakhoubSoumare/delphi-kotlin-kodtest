package kodTest.Winassist

import kotlin.test.Test
import kotlin.test.assertTrue

class FastPrisTest {

    @Test
    fun `kontroll av fastpris resulterar typ F och kod IS`() {

        // DM.lager1 är en färdigbyggd testdata från companion
        val lager = DM.lager1  // artikel1 i DM har fastPris=true

        // Ignorera antal parameter med _
        val (_, rader) = KodTest().TestaInkopspriserBtnClick(listOf(lager))

        val rad = rader.first()

        assertTrue(rad.contains("typ=F"))
        assertTrue(rad.contains("kod=IS"))
    }
}