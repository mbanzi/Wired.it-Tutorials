GIARDUINO
=========

Giarduino è un sistema di gestione remota del vostro giardino.
E' composto da un'Arduino accoppiata ad un Ethernet Shield che
permette di monitorare l'umidità del terreno, la temperatura e la 
quantità di luce ricevuta da una pianta. Inoltre permette di 
controllare remotamente la valvola del sistema di innaffiatura
perciò da qualunque parte del mondo potrete tenere sotto controllo
le vostre piante ed azionare l'innaffiatore per poi spegnerlo quando
l'umidità della pianta ha raggiunto il livello ottimale.

Costruzione
===========

Collegate l'ethernet shield all'arduino uno e mega (se avete uno shield 
versione 5, quelli precedenti non funzionano sulla mega)
Collegate la valvola di controllo dell'acqua al pin 6 tramite un relè.
Collegate i sensori di temperatura, luce e umidità ai piedini analogici
0, 1 e 2.

A questo punto vi serve un codice identificativo univoco per il vostro 
giarduino in modo che l'interfaccia su internet sia in grado di comandarlo
(e non quello del vicino!)

andate su http://giarduino.cogitanz.com/register.php e vi apparirà un codice
come questo 5A8BA768E86F5D3008A2DB94AF0CD7E6 copiatelo ed incollatelo nel
codice arduino alla riga che dice :
String myUUID    = "5A8BA768E86F5D3008A2DB94AF0CD7E6";

Dovete inoltre assegnare a mano un'indirizzo IP all'arduino e questo dipende
dalla rete di casa vostra. Nel nostro esempio il router adsl fornisce 
indirizzi IP che iniziano per 192.168.1.xxx e abbiamo scelto un numero alto,
177, per non entrare in conflitto con i pc che avete a casa. (se avete più di
177 computer collegati alla rete di casa complimenti...)

caricate il codice sulla vostra arduino e collegatelo alla rete tramite un 
cavo e alimentate la scheda.

a questo punto recatevi su http://giarduino.cogitanz.com e inserite il codice
del vostro giarduino 5A8BA768E86F5D3008A2DB94AF0CD7E6 e inizierete a vedere
i dati che arrivano dalla scheda mentre premendo l'interruttore on/off
sullo schermo possiamo controllare lo stato di accensione spegnimento della
valvola (o pompa) di innaffiatura.

prima che il sistema sia funzionante a pieno dovete tarare i vostri sensori!!






