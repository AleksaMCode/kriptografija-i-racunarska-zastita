# Kriptografija i računarska zaštita <img width="30px" src="https://raw.githubusercontent.com/AleksaMCode/kriptografija-i-racunarska-zastita/main/crypto.png" />
Rješenje rokova iz predmeta *Kriptografija i računarska zaštita* na Elektrotehničkom fakultetu u Banjoj Luci.

* [Ispit 07.10.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20201007)
* [Ispit 16.09.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20200916)
* [Ispit 02.09.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20200902)
* [Ispit 19.08.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20200819)
* [Ispit 15.07.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20200715)
* [Ispit 01.07.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20200701)
* [Ispit 10.06.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20200610)
* [Ispit 12.02.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20200212)
* [Ispit 29.01.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20200129)
* [Ispit 20.12.2019.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20191220)
* [Ispit 22.11.2019.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/ispit_20191122)
* [2. kol. 23.01.2020.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/kolokvijum_20200123)
* [2. kol. 25.01.2019.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/kolokvijum_20190125)
* [2. kol. 18.01.2018.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/kolokvijum_20180118)
* [2. kol. 18.01.2017.](https://github.com/AleksaMCode/kriptografija-i-racunarska-zastita/tree/main/kolokvijum_20170118)

## Biblioteka algoritama
<p align="justify">Implementacija algoritama koji dolaze na prvom dijelu ispita, u <b>C#</b>, sa ciljem automatizacije i ubrzavanja procesa rješavanja takvih zadataka.</p>
<ol>
    <li><a href="./Biblioteka/RC4/Rc4Algo.cs">RC4</a></li>
</ol>

### RC4
Neka je dat ključ u ASCII formatu kao <b>28221002</b> i neka je dužina vektora stanja 56 bita.

- Primjer korištenja klase <i>Rc4Algo</i> za enkripciju ulaznog teksta <b>ACAA</b> koji je data u `string` formatu.
```C#
int[] key = { '2', '8', '2', '2', '1', '0', '0', '2' };
var rc4 = new Rc4Algo(key);
string opentext = "ACAA";
int stateVectorLen = 56 / 8; // konvertovanje bita u bajtove
rc4.Encrypt(stateVectorLen, opentext);
```
- Primjer korištenja klase <i>Rc4Algo</i> za enkripciju ulaznog teksta <b>ACAA</b> koji je data u `hex` formatu, tj. kao `0xacaa`.
```C#
int[] key = { '2', '8', '2', '2', '1', '0', '0', '2' };
var rc4 = new Rc4Algo(key);
int[] opentextInHex = { 0xac, 0xaa };
int stateVectorLen = 56 / 8; // konvertovanje bita u bajtove
rc4.Encrypt(stateVectorLen, opentextInHex);
```
- Primjer korištenja klase <i>Rc4Algo</i> kada zadatak samo traži da se izračuna vektor stanja za ulazne parametre.
```C#
int[] key = { '2', '8', '2', '2', '1', '0', '0', '2' };
var rc4 = new Rc4Algo(key);
int stateVectorLen = 56 / 8; // konvertovanje bita u bajtove
rc4.OnlyKSA(stateVectorLen);
```

## Napomena
Rješenja zadataka mogu sadržati greške. Sve greške možete prijaviti putem [email-a](mailto:aleksamcode@gmail.com?subject=[GitHub-Kriptografija-rjesenja-ispita-greska]).