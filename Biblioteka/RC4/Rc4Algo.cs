using System;

namespace RC4algo
{
    /// <summary>
    /// Pojednostavljena implementacija RC4 algoritma koja se koristi na ispitu iz <em>Kriptografija i računarska zaštita</em> na Elektrotehničkom fakultetu u Banjoj Luci.
    /// </summary>
    public class Rc4Algo
    {
        /// <summary>
        /// Vektor stanja.
        /// </summary>
        private int[] S { get; set; }

        /// <summary>
        /// Kljuc promjenljive duzine, od 1 do 256 B.
        /// </summary>
        private int[] Key { get; set; }


        /// <summary>
        /// Rezultat enkripcije/dekripcije.
        /// </summary>
        private int[] Result { get; set; }

        /// <summary>
        /// Konstruktor od <see cref="Rc4Algo"/> koji prihvata kljuc.
        /// </summary>
        /// <param name="key"></param>
        public Rc4Algo(int[] key)
        {
            if (key.Length > 255)
            {
                Array.Resize<int>(ref key, 255);
            }
            Key = key;
        }

        /// <summary>
        /// Enkripcija koristenjem <em>opentext</em>-a u <see cref="string"/> formatu. KSA + PRGA faze.
        /// </summary>
        /// <param name="stateVectorLen">Velicina vektora stanja u bajtovima.</param>
        /// <param name="plaintext">Neenkriptovani ulazni podaci.</param>
        public void Encrypt(int stateVectorLen, string plaintext)
        {
            KeySchedulingAlgorithmPhase(stateVectorLen);
            PseudoRandomGenerationAlgorithmPhase(plaintext);
        }

        /// <summary>
        /// Enkripcija koristenjem <em>opentext</em>-a u u <see cref="int"/>[] formatu. KSA + PRGA faze.
        /// </summary>
        /// <param name="stateVectorLen">Velicina vektora stanja u bajtovima.</param>
        /// <param name="plaintext">Neenkriptovani ulazni podaci.</param>
        public void Encrypt(int stateVectorLen, int[] plaintext)
        {
            KeySchedulingAlgorithmPhase(stateVectorLen);
            PseudoRandomGenerationAlgorithmPhase(plaintext);
            PrintVectorS();
            PrintResult();
        }

        /// <summary>
        /// Dekripcija koristenjem <em>ciphertext</em>-a u u <see cref="string"/> formatu.
        /// </summary>
        /// <param name="stateVectorLen">Velicina vektora stanja u bajtovima.</param>
        /// <param name="ciphertext">Enkriptovan podatak.</param>
        public void Decrypt(int stateVectorLen, string ciphertext)
        {
            Encrypt(stateVectorLen, ciphertext);
        }

        /// <summary>
        /// Dekripcija koristenjem <em>ciphertext</em>-a u u <see cref="int"/>[] formatu.
        /// </summary>
        /// <param name="stateVectorLen">Velicina vektora stanja u bajtovima.</param>
        /// <param name="ciphertext">Enkriptovan podatak.</param>
        public void Decrypt(int stateVectorLen, int[] ciphertext)
        {
            Encrypt(stateVectorLen, ciphertext);
        }

        /// <summary>
        /// Koristi se za zadatke u kojima samo treba izracunati vektora stanja.
        /// </summary>
        /// <param name="stateVectorLen">Velicina vektora stanja u bajtovima.</param>
        /// <returns>Vektor stanja <see cref="S"/>.</returns>
        public void OnlyKSA(int stateVectorLen)
        {
            KeySchedulingAlgorithmPhase(stateVectorLen);
            PrintVectorS();
        }

        /// <summary>
        /// KSA (engl. key-scheduling algorithm) – inicijalizuje se permutacija u nizu S.
        /// Prvo se niz S inicijalizuje vrijednostima od 0 do stateVectorLen u rastućem poretku,
        /// nakon čega se vrši permutacija stateVectorLen puta koristeći bajtove iz ključa.
        /// </summary>
        /// <param name="stateVectorLen">Velicina vektora stanja u bajtovima.</param>
        public void KeySchedulingAlgorithmPhase(int stateVectorLen)
        {
            if (stateVectorLen >= 255)
            {
                stateVectorLen = 255;
            }

            // KSA prva faza - niz S inicijalizuje vrijednostima od 0 do stateVectorLen u rastućem poretku
            for (int i = 0; i < stateVectorLen; ++i)
            {
                S[i] = i;
            }

            // KSA druga faza - inicijalna permutacija vektora S
            for (int i = 0, j = 0; i < S.Length; ++i)
            {
                j = (j + S[i] + Key[i % Key.Length]) % S.Length;

                // swap vrijednosti S[i] i S[j]
                Swap(i, j);
            }
        }

        /// <summary>
        /// Generisemo rezultujuci niz algoritma.
        /// </summary>
        /// <param name="data">Ulazni podaci u <see cref="string"/> formatu koji se enkriptuju/dekriptuju.</param>
        public void PseudoRandomGenerationAlgorithmPhase(string data)
        {
            Result = new int[data.Length];

            for (int iteration = 0, i = 0, j = 0; iteration < data.Length; ++iteration)
            {
                // inkrementujemo promjenljivu i
                i = (i + 1) % S.Length;

                // dodajemo i-ti element vektora stanja na postojecu vrijednost promjenljive j
                j = (j + S[i]) % S.Length;

                // swap vrijednosti S[i] i S[j]
                Swap(i, j);

                // modularnu sumu S[i] + S[j] koristimo kao index vektora stanja S ciju vrijednost smjestamo u promjenljivu k
                int k = S[(S[i] + S[j]) % S.Length];

                // rezultujuca vrijednost k se XOR-uje sa bajtom plaintext-a
                Result[iteration] = data[iteration] ^ k;
            }
        }

        /// <summary>
        /// Generisemo rezultujuci niz algoritma.
        /// </summary>
        /// <param name="data">Ulazni podaci u <see cref="byte"/>[] formatu koji se enkriptuju/dekriptuju.</param>
        public void PseudoRandomGenerationAlgorithmPhase(int[] data)
        {
            Result = new int[data.Length];

            for (int iteration = 0, i = 0, j = 0; iteration < data.Length; ++iteration)
            {
                // inkrementujemo promjenljivu i
                i = (i + 1) % S.Length;

                // dodajemo i-ti element vektora stanja na postojecu vrijednost promjenljive j
                j = (j + S[i]) % S.Length;

                // swap vrijednosti S[i] i S[j]
                Swap(i, j);

                // modularnu sumu S[i] + S[j] koristimo kao index vektora stanja S ciju vrijednost smjestamo u promjenljivu k
                int k = S[(S[i] + S[j]) % S.Length];

                // rezultujuca vrijednost k se XOR-uje sa bajtom plaintext-a
                Result[iteration] = data[iteration] ^ k;
            }
        }

        /// <summary>
        /// Ispis vektora stanja <see cref="S"/>.
        /// </summary>
        public void PrintVectorS()
        {
            Console.Write("S -> [ ");
            for (int i = 0; i < S.Length; ++i)
            {
                if (i != S.Length - 1)
                {
                    Console.Write(S[i] + ",");
                }
                else
                {
                    Console.Write(S[i]);
                }
            }
            Console.Write(" ]\n");
        }


        /// <summary>
        /// Ispis rezultata <see cref="Result"/> enkripcije/dekripcije u heksadecimalnom formatu.
        /// </summary>
        public void PrintResult()
        {
            Console.Write("result -> [ ");
            for (int i = 0; i < Result.Length; ++i)
            {
                if (i != Result.Length - 1)
                {
                    Console.Write("0x" + Result[i].ToString("X") + ",");
                }
                else
                {
                    Console.Write("0x" + Result[i].ToString("X"));
                }
            }
            Console.Write(" ]\n");
        }

        /// <summary>
        /// Vrijednost S[i] i S[j] mijenjaju mjesta.
        /// </summary>
        /// <param name="i">Index prvog elementa.</param>
        /// <param name="j">Index drugog elementa.</param>
        private void Swap(int i, int j)
        {
            int temp = S[i];
            S[i] = S[j];
            S[j] = temp;
        }
    }
}