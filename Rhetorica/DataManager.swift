//
//  stylisticDevice.swift
//  Cicero
//
//  Created by Nick Podratz on 14.09.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import Foundation


let latinAlphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

/// A singleton class for the Data-access of the business layer. The singstatic leton's name is sharedInstance.
final class DataManager: NSObject {
    
    // TODO: Complete singleton pattern
    // TODO Devices in .plist, read from disc and put into dictionary.
    static let sharedInstance = DataManager()
    
    // Transfer when class-variables are available into DeviceList class
    lazy var selectedList: DeviceList = {
        // Load selected List from NSUserDefaults
        let loadedListTitle: String? = NSUserDefaults.standardUserDefaults().valueForKey("Selected List") as? String
        let loadedList: DeviceList? = DataManager.sharedInstance.allDeviceLists.filter{$0.title == loadedListTitle}.first
        
        if loadedList?.elements.isEmpty == false {
            return loadedList!
        } else {
            println("couldn't load Device List, set to fewDevices")
            return DataManager.fewDevices
        }
    }()
    
    var allDeviceLists = [fewDevices, someDevices, allDevices, favorites]
    
    /// An immutable collection of the most important Stylistic Devices.
    static var fewDevices: DeviceList {
        return DeviceList(
            title: "Wichtigste Stilmittel",
            editable: false,
            elements: [allegorie, alliteration, anapher, antithese, allusion, antiklimax, chiasmus, ellipse, euphemismus, floskel, hyperbel, imperativ, inversion, ironie, klimax, metapher, neologismus, paradoxon, parallelismus, personifikation, pointe, redundanz, repetitio, rhetorische_frage, sarkasmus, symbol, synonym, untertreibung, vergleich, vulgarismus]
        )

    }
    /// An immutable collection of some Stylistic Devices.
    static var someDevices: DeviceList {
        return DeviceList(
            title: "Einige Stilmittel",
            editable: false,
            elements: [accumulatio, addierendeZusammensetzung, adynaton, aischrologie, allegorie, alliteration, anapher, antithese, antonomasie, allusion, anastrophe, anthropomorphismus, antiklimax, antiphrasis, archaismus, asyndeton, buchstabendreher, chiasmus, chiffre, concessio, correctio, diaphora, diminutiv, dysphemismus, elision, ellipse, enjambement, enumeration, epitheton, eponomasie, etymologische_figur, euphemismus, evidenz, exclamatio, exemplum, floskel, homoioteleuton, hyperbaton, hyperbel, hypotaxe, imperativ, interjektion, inversion, invokation, ironie, katachrese, klimax, litotes, metapher, neologismus, onomatopoesie, oxymoron, palindrom, paradoxon, parallelismus, parataxe, parenthese, periphrase, personifikation, pleonasmus, pluralis_majestatis, pointe, redundanz, repetitio, rhetorische_frage, sarkasmus, scheindefinition, sentenz, solözismus, stabreim, sustentio, symbol, synekdoche, synonym, Tetrakolon, trikolon, untertreibung, variatio, verdinglichung, vergleich, vulgarismus, wortspiel, zynismus]
        )
    }
    
    /// An immutable collection of all Stylistic Devices.
    static var allDevices: DeviceList {
        return DeviceList(
            title: "Alle Stilmittel",
            editable: false,
            elements: [accumulatio, addierendeZusammensetzung, adynaton, aischrologie, allegorie, alliteration, anapher, antithese, antonomasie, apokoinu, allusion, alogismus, anadiplose, anakoluth, anastrophe, anthropomorphismus, antizipation, antiklimax, antilabe, antiphrasis, antitheton, aposipese, apostrophe, archaismus, assonanz, asyndeton, bathos, brachylogie, brevitas, buchstabendreher, chiasmus, chiffre, chrie, conversio, concessio, constructio_ad_sensum, contradicto_in_adiecto, correctio, diaphora, diakolon, diminutiv, dysphemismus, elision, ellipse, emphase, enjambement, enumeration, epanalepse, epanodos, epipher, epiphrase, epitheton, eponomasie, etymologische_figur, euphemismus, evidenz, exclamatio, exemplum, floskel, geminatio, gleichnis, hendiadyoin, homoioteleuton, homoioarkton, hypallage, hyperbaton, hyperbel, hypotaxe, hysteron_proteron, imperativ, inkonzinnität, interjektion, inversion, invokation, ironie, kakophonie, katachrese, klimax, kyklos, litotes, metapher, metonymie, montage, neologismus, onomatopoesie, oxymoron, palindrom, paradoxon, paralipse, parallelismus, paraphrase, parataxe, parenthese, paronomasie, pars_pro_toto, periphrase, personifikation, pleonasmus, pluralis_auctoris, pluralis_majestatis, pluralis_modestiae, pointe, polyptoton, polysyndeton, prokatalepsis, redundanz, repetitio, rhetorische_frage, sarkasmus, scheindefinition, sentenz, solözismus, stabreim, stichomythie, sustentio, syllepse, symbol, synästhesie, synekdoche, synonym, tautologie, Tetrakolon, totemismus, totum_pro_parte, trikolon, tricolon_in_membris_crescentibus, untertreibung, variatio, verdinglichung, vergleich, vulgarismus, wortspiel, zeugma, zynismus]
        )
    }
    
    /// A mutable collection of the user's favored Stylistic Devices.
    static var favorites = DeviceList(
        title: "Favoriten",
        editable: true,
        elements: [StylisticDevice]()
    )
    
    // A
    
    static let accumulatio = StylisticDevice(
        title: "Accumulatio",
        definition: "Eine Ansammlung thematisch zusammengehörender Wörter unter einem genannten oder nicht genannten Oberbegriff.",
        example: "„Feld, Wald und Wiesen“\n„Sonne, Mond und Sterne“",
        wikipedia: "http://de.wikipedia.org/wiki/Accumulatio"
    )
    
    static let addierendeZusammensetzung = StylisticDevice(
        title: "Addierende Zusammensetzung",
        definition: "Zwei gleichberechtigte, einander widersprechende Glieder.",
        example: "„traurigfroh“\n„du übersinnlich-sinnlicher Freier“")
    
    static let adynaton = StylisticDevice(
        title: "Adynaton",
        definition: "Das Unmögliche bzw. ein widersinnliches Beispiel (meist Natur) verdeutlicht das Nicht-Eintreten eines Ereignisses.",
        example: "„Kamel durch das Nadelör“",
        wikipedia: "http://de.wikipedia.org/wiki/Adynaton")
    
    static let aischrologie = StylisticDevice(
        title: "Aischrologie",
        definition: "Eine abwertende Umschreibung. (eventuell Teil einer Schimpfrede)",
        example: "„Blechkübel“ (Auto)",
        wikipedia: "http://de.wikipedia.org/wiki/Aischrologie")
    
    static let allegorie = StylisticDevice(
        title: "Allegorie",
        definition: "Ein fassbares, personifiziertes Bild, welches der Darstellung eines abstrakten Begriffes dient.",
        example: "Justitia",
        wikipedia: "http://de.wikipedia.org/wiki/Allegorie")
    
    static let alliteration = StylisticDevice(
        title: "Alliteration",
        definition: "Die Wiederholung der Anfangsbuchstaben in aufeinanderfolgenden Wörtern.",
        example: "„Milch macht müde Männer munter“",
        wikipedia: "http://de.wikipedia.org/wiki/Alliteration")
    
    static let anapher = StylisticDevice(
        title: "Anapher",
        definition: "Die Wiederholung von Wörtern am Anfang.",
        example: "Endlich... / endlich... / endlich...",
        wikipedia: "http://de.wikipedia.org/wiki/Anapher")
        
    static let antithese = StylisticDevice(
        title: "Antithese",
        definition: "Die Zusammensetzung entgegengesetzter (antithetischer) Begriffe.",
        example: "Jung und Alt, Gut und Böse\n „Eng ist die Welt und das Gehirn ist weit“",
        wikipedia: "http://de.wikipedia.org/wiki/Antithese")

    
    static let antonomasie = StylisticDevice(
        title: "Antonomasie",
        definition: "Ein charakteristischer Begriff anstatt eines Eigennames.",
        example: "„Walzerkönig“ (für Strauss)",
        wikipedia: "http://de.wikipedia.org/wiki/Antonomasie")

    
    static let apokoinu = StylisticDevice(
        title: "Apokoinu",
        definition: "Ein Satzteil, der gleichmäßig zu zwei beigeordneten Sätzen gehört, steht ohne Verbindungswort in der Mitte.",
        example: "„du bist alt bist du“",
        wikipedia: "http://de.wikipedia.org/wiki/Apokoinu")

    
    static let allusion = StylisticDevice(
        title: "Allusion",
        definition: "Eine Anspielung.",
        example: "„Sie wissen, was ich meine.“\n„Er ist ein wahrer Romeo in Bezug auf Frauen.“",
        wikipedia: "http://de.wikipedia.org/wiki/Allusion")

    
    static let alogismus = StylisticDevice(
        title: "Alogismus",
        definition: "Drückt einen unlogischen Sachverhalt aus oder stellt eine Überlegung dar, die sich selbst oder der Logik widerspricht.",
        example: "„Sind nackte Frauen intelligent?“\n„Nachts ist es kälter als draußen.“",
        wikipedia: "http://de.wikipedia.org/wiki/Alogismus")

    
    static let anadiplose = StylisticDevice(
        title: "Anadiplose",
        definition: "Die Wiederholung eines (satz-/)versschließenden Wortes am Beginn des nächsten Satzes/Verses. (Schema: … x / x …) (Sonderfall der Repetitio)",
        example: "„Mit dem Schiffe spielen Wind und Wellen,\nWind und Wellen spielen nicht mit seinem Herzen.“ (Johann Wolfgang von Goethe)",
        wikipedia: "http://de.wikipedia.org/wiki/Anadiplose")

    
    static let anakoluth = StylisticDevice(
        title: "Anakoluth",
        definition: "Ein Satzbruch, eine plötzliche Änderung in der grammatischen Konstruktion eines Satzes.",
        example: "„Korf erfindet eine Mittagszeitung,\nwelche, wenn man sie gelesen hat,/nist man satt.“ (Christian Morgenstern)",
        wikipedia: "http://de.wikipedia.org/wiki/Anakoluth")

    
    static let anastrophe = StylisticDevice(
        title: "Anastrophe",
        definition: "Die Vertauschung zweier zusammengehörender Wörter.",
        example: "„der Verstellung schwere Kunst“ anstelle von: „die schwere Kunst der Verstellung“",
        wikipedia: "http://de.wikipedia.org/wiki/Anastrophe_(Rhetorik)")

    
    static let anthropomorphismus = StylisticDevice(
        title: "Anthropomorphismus",
        definition: "Das Zusprechen menschlicher Eigenschaften auf unbelebte Gegenstände.",
        example: "„Die Frau schüttet den Tee aus der Kannennase“",
        wikipedia: "http://de.wikipedia.org/wiki/Anthropomorphismus")
    
    
    static let antiklimax = StylisticDevice(
        title: "Antiklimax",
        definition: "Eine Abfallende Steigerung. (Gegenteil zur Klimax)",
        example: "„Urahne, Großmutter, Mutter und Kind“",
        wikipedia: "http://de.wikipedia.org/wiki/Antiklimax")
    
    static let antilabe = StylisticDevice(
        title: "Antilabe",
        definition: "Derm Text einer Zeile wird auf mehrere Sprecher verteilt.",
        example: "„DER HERR: Kennstaust? / MEPHISTOPHELES: Den Doktor? / DER HERR: Meinen Knecht!“ (Goethe: Faust I)",
        wikipedia: "http://de.wikipedia.org/wiki/Antilabe")
    
    static let antiphrasis = StylisticDevice(
        title: "Antiphrasis",
        definition: "Es soll das Gegenteil des eigentlich Gesagten ausgedrücken und kann sich auf ein einzelnes Wort, einen Satz oder eine Passage beziehen. Es ist eine der häufigsten Formen der Ironie.",
        example: "„Hast du heute wieder gute Laune!“",
        wikipedia: "http://de.wikipedia.org/wiki/Antiphrasis")
    
    static let antitheton = StylisticDevice(
        title: "Antitheton",
        definition: "Die Gegenüberstellung zweier entgegengesetzter, sich nicht widersprechender Gedanken.",
        example: "„Das wird Schaden, nicht Nutzen bringen.“",
        wikipedia: "http://de.wikipedia.org/wiki/Antitheton")
    
    static let antizipation = StylisticDevice(
        title: "Antizipation",
        definition: "Eine Vorausschau oder ein Zeitsprung in die Zukunft, der Lesererwartungen weckt.",
        example: "„Wohlan, nun waltender Gott,“ [sagte Hildebrand], „Unheil geschieht: (Hildebrandslied)“",
        synonym: "Prolepse",
        wikipedia: "http://de.wikipedia.org/wiki/Antizipation_(Literatur)")
    
    static let aposipese = StylisticDevice(
        title: "Aposiopese",
        definition: "Der plötzliche Abbruch eines Satzes.",
        example: "„Seht mal, was ich …“",
        wikipedia: "http://de.wikipedia.org/wiki/Aposiopese")
    
    static let apostrophe = StylisticDevice(
        title: "Apostrophe",
        definition: "Die Hinwendung zum Publikum, einer imaginäre Person oder Sache.",
        example: "„Alter Freund! Immer getreuer Schlaf, fliehst du mich?“",
        wikipedia: "http://de.wikipedia.org/wiki/Apostrophe")
    
    static let archaismus = StylisticDevice(
        title: "Archaismus",
        definition: "Ein veralteter sprachlicher Ausdruck",
        example: "„Wams“ für: „Jacke“\n„gülden“ für: „golden“",
        wikipedia: "http://de.wikipedia.org/wiki/Archaismus")
    
    static let assonanz = StylisticDevice(
        title: "Assonanz",
        definition: "Ein Vokalischer Halbreim.",
        example: "„Ottos Mops trotzt.“ (Ernst Jandl)\n„Unterpfand – wunderbar“",
        wikipedia: "http://de.wikipedia.org/wiki/Assonanz_(Lyrik)")
    
    static let asyndeton = StylisticDevice(
        title: "Asyndeton",
        definition: "Unverbundene Aneinanderreihung gleichwertiger Elemente ohne Verwendung von Bindungswörtern oder Konjunktionen.",
        example: "„Wasser, Feuer, Erde, Luft – ewig werden sie bestehen.“",
        wikipedia: "http://de.wikipedia.org/wiki/Asyndeton")
    
    
    // B
    
    static let bathos = StylisticDevice(
        title: "Bathos",
        definition: "Eine Gegenüberstellung eines höheren Wertes mit einem niedrigeren.",
        example: "„Die Explosion zerstörte alle Häuser auf der anderen Straßenseite und meinen Briefkasten.“",
        wikipedia: "http://de.wikipedia.org/wiki/Bathos")
    
    static let brachylogie = StylisticDevice(
        title: "Brachylogie",
        definition: "Die Auslassung von Satzgliedern.",
        example: "„Das Gras verdorrt in der Sonne, das Hähnchen im Grill.“",
        wikipedia: "http://de.wikipedia.org/wiki/Brachylogie")
    
    static let brevitas = StylisticDevice(
        title: "Brevitas",
        definition: "Eine auffällig knappe Ausdrucksweise, die oft durch Ellipsen unterstützt wird.",
        example: "„Wenn du mal gesellig im Wirtshaus gezecht hast, dich mit Freunden vergnügt hast und dich des Lebens gefreut hast, kommst du nichts ahnend nach Hause und staunst nicht schlecht: Auto weg, Frau weg, Geld weg.“")
    
    static let buchstabendreher = StylisticDevice(
        title: "Buchstabendreher",
        definition: "Meist eine Vertauschung der anlautenden Konsonanten (seltener der Vokale) zweier zusammengehöriger Wörter, sodass sich ein neuer, meist alberner Sinn oder Klang ergibt. (Sonderfall: Schüttelreim)",
        example: "„Hauptpreis sind ein Paar kopflose Schnurhörer“ („schnurlose Kopfhörer“)\n„Wechstaben verbuchseln“ („Buchstaben verwechseln“)\n„Liebes Lästerschwein, bitte ...“ („Schwesterlein“)")
   
    
    // C
    
    static let chiasmus = StylisticDevice(
        title: "Chiasmus",
        definition: "Die symmetrische Überkreuzstellung von syntaktisch oder semantisch entsprechenden Satzteilen.",
        example: "„Ich bin groß, klein bist du.“\n„Wie viel schneller man die Welt mit einem Könige versorge, als Könige mit einer Welt.“\n„Er liebt Rosen, Nelken mag er nicht.“",
        wikipedia: "http://de.wikipedia.org/wiki/Chiasmus")
    
    static let chiffre = StylisticDevice(
        title: "Chiffre",
        definition: "Zeichen, dessen Inhalt rätselhaft und static letztlich nicht für den Leser zusammenhangslos zu erfassen ist.",
        example: "„Stadt“ als Chiffre der Hoffnungslosigkeit in der expressionistischen Lyrik",
        wikipedia: "http://de.wikipedia.org/wiki/Chiffre_(Literatur)")
    
    static let chrie = StylisticDevice(
        title: "Chrie",
        definition: "Ein Merkspruch, eine Spruchweisheit oder ethische Maxime.",
        example: "„Den Freunden Gutes tun, den Feinden Böses tun.“",
        wikipedia: "http://de.wikipedia.org/wiki/Chrie")
    
    static let conversio = StylisticDevice(
        title: "Conversio",
        definition: "Die Wiederkehr eines Wortes am Satzende.",
        example: "„Er hatte am Ende nur noch Schmerzen, nur Schmerzen.“")
    
    static let concessio = StylisticDevice(
        title: "Concessio",
        definition: "Das Eingestehen der Richtigkeit eines gegnerischen Argumentes, welches durch stärkere eigene Argumente umgehend unwirksam gemacht wird.",
        example: "„Er mag sich unmoralisch verhalten haben, aber bestrafen kann man ihn dafür nicht.“",
        wikipedia: "http://de.wikipedia.org/wiki/Concessio")
    
    static let constructio_ad_sensum = StylisticDevice(
        title: "Constructio ad sensum",
        definition: "Eine sinngemäße Satzkonstruktion, die formal gegen die Regeln der grammatischen Kongruenz verstößt.",
        example: "„Er liebte das Mädchen und wollte sie heiraten.“ (formal richtig wäre: „… und wollte es heiraten.“)\n„Der ganze Haufen stürzte auf ihn zu. Sie warfen ihn in heißen Teer und federten ihn dann.“ (formal richtig wäre: „Er warf ihn …“)\n„Mehr als ein Drittel der Beschäftigten legten die Arbeit nieder.“ (formal richtig wäre: „… legte …“)\n„Das König der Biere“ (formal richtig wäre: „Der König …“)",
        wikipedia: "http://de.wikipedia.org/wiki/constructio_ad_sensum")
    
    static let contradicto_in_adiecto = StylisticDevice(
        title: "Contradictio in adiecto",
        definition: "widersprüchliche Kombination von Adjektiv und Substantiv. (Sonderfall des Oxymoron)",
        example: "„fünfeckiger Kreis“, „geschliffener Rohdiamant“, „gerade Kurve“, „alter Jüngling“, „ehemalige Zukunft“ (Ödön von Horváth: Jugend ohne Gott)")
    
    static let correctio = StylisticDevice(
        title: "Correctio",
        definition: "Eine (oft eingeschobene) Korrektur.",
        example: "„Es war ein Erfolg – was sage ich – ein Triumph.“",
        wikipedia: "http://de.wikipedia.org/wiki/Correctio")

    
    // D
    
    static let diaphora = StylisticDevice(
        title: "Diaphora",
        definition: "Die Wiederholung desselben Wortes in verschiedenen Bedeutungen.",
        example: "„Auf acht Leute acht geben“",
        wikipedia: "http://de.wikipedia.org/wiki/Diaphora")
    
    static let diakolon = StylisticDevice(
        title: "Dikolon",
        definition: "Ein zweigliedriger Ausdruck, bei dem die Teile semantisch gleich aufgebaut sind und zueinander parallel und/oder chiastisch stehen.",
        example: "„Biblische Bilder sind häufig verwendete Allegorien, biblische Gleichnisse oft herangezogene Metaphern.“",
        wikipedia: "http://de.wikipedia.org/wiki/Dikolon")
    
    static let diminutiv = StylisticDevice(
        title: "Diminutiv",
        definition: "Die Verniedlichungsform eines Substantives.",
        example: "„Häuschen“, „Zicklein“",
        wikipedia: "http://de.wikipedia.org/wiki/Diminutiv")
    
    static let dysphemismus = StylisticDevice(
        title: "Dysphemismus",
        definition: "Eine abwertende, wertverschlechternde Umschreibung oder Wortschöpfung. (Gegenteil von Euphemismus)",
        example: "„Saftschubse“ statt: „Stewardess“\n„Penner“ statt: „Obdachlose(r)“\n„Ungeziefer“ statt: „Insekten“\n„sich zusammenrotten“ statt: „sich versammeln“",
        synonym: "Pejoration",
        wikipedia: "http://de.wikipedia.org/wiki/Dysphemismus")
    
    
    // E
    
    static let elision = StylisticDevice(
        title: "Elision",
        definition: "Das Weglassen eines oder mehrerer meist unbetonter Laute. (in der Orthographie gelegentlich durch einen Apostroph gekennzeichnet)",
        example: "„bracht“ statt: „brachte“\n„fröhl'chen“ statt: „fröhlichen“",
        wikipedia: "http://de.wikipedia.org/wiki/Elision")
    
    static let ellipse = StylisticDevice(
        title: "Ellipse",
        definition: "Die Auslassung von Satzteilen.",
        example: "„Na und?“\n„Wer? Ich!“\n„Ich kann dies, du nicht“",
        wikipedia: "http://de.wikipedia.org/wiki/Ellipse_(Linguistik)")
    
    static let emphase = StylisticDevice(
        title: "Emphase",
        definition: "Die Nachdrückliche Hervorhebung eines Wortes zur Gefühlsverstärkung.",
        example: "„Menschen! Menschen! Falsche heuchlerische Krokodilsbrut!“ (Friedrich Schiller)",
        wikipedia: "http://de.wikipedia.org/wiki/Emphase")
    
    static let enjambement = StylisticDevice(
        title: "Enjambement",
        definition: "Die Fortführung eines Satzes über das Vers-/Zeilenende hinaus.",
        example: "„Die Wellen schaukeln /\nDen lustigen Kahn“ (Heinrich Heine)",
        wikipedia: "http://de.wikipedia.org/wiki/Enjambement")
    
    static let enumeration = StylisticDevice(
        title: "Enumeration",
        definition: "Eine Aufzählung.",
        example: "„die grünen, die blauen, die roten und die gelben Bälle“",
        wikipedia: "http://de.wikipedia.org/wiki/Enumeration")
    
    static let epanalepse = StylisticDevice(
        title: "Epanalepse",
        definition: "Die Wiederholung eines Wortes oder einer Wortgruppe am Satzanfang oder im Satz.",
        example: "„Mein Vater, mein Vater, jetzt fasst er mich an.“ (Johann Wolfgang von Goethe: Erlkönig)",
        wikipedia: "http://de.wikipedia.org/wiki/Epanalepse")
    
    static let epanodos = StylisticDevice(
        title: "Epanodos",
        definition: "Die Wiederholung von Worten in umgekehrter Reihenfolge. (Sonderfall des Chiasmus)",
        example: "„Wer nicht kann, was er will, der wolle, was er kann.“ (Leonardo da Vinci)",
        wikipedia: "http://de.wikipedia.org/wiki/Epanodos")
    
    static let epipher = StylisticDevice(
        title: "Epipher",
        definition: "Eine Wiederholung am Satz- oder Versende. (Schema: … x / … x) (Sonderfall der Repetitio)",
        example: "„Ich fordere Moral, du lebst Moral.“",
        synonym: "Conversio",
        wikipedia: "http://de.wikipedia.org/wiki/Epipher")
    
    static let epiphrase = StylisticDevice(
        title: "Epiphrase",
        definition: "Ein syntaktisch scheinbar beendeter Satz erhält Nachtrag zur Abrundung.",
        example: "„Mein Retter seid Ihr und mein Engel.“",
        wikipedia: "http://de.wikipedia.org/wiki/Epiphrase")
    
    static let epitheton = StylisticDevice(
        title: "Epitheton",
        definition: "Ein eigentlich nicht notwendiges Beiwort.",
        example: "„der listenreiche Odysseus, die rosenfingrige Eos“",
        wikipedia: "http://de.wikipedia.org/wiki/Epitheton")
    
    static let eponomasie = StylisticDevice(
        title: "Eponomasie",
        definition: "Die Ersetzung eines Begriffs durch den kennzeichnenden Eigennamen einer bekannten Beispielfigur.",
        example: "„ein ungläubiger Thomas“ statt: „Skeptiker“",
        wikipedia: "http://de.wikipedia.org/wiki/Eponomasie")
    
    static let etymologische_figur = StylisticDevice(
        title: "Etymologische Figur",
        definition: "Ein mit einem stammverwandten Substantiv verbundenes Verb.",
        example: "„einen Kampf kämpfen“\n„eine Schlacht schlagen“\n„in Ruhe ruhen“\n„ein Spiel spielen“")
    
    static let euphemismus = StylisticDevice(
        title: "Euphemismus",
        definition: "Eine Beschönigende Umschreibung. (Gegenteil: Dysphemismus)",
        example: "„kräftig“ statt: „dick“\n„das Zeitliche segnen“ statt: „sterben“\n„Seniorenresidenz“ statt: „Altenheim“",
        wikipedia: "http://de.wikipedia.org/wiki/Euphemismus")
    
    static let evidenz = StylisticDevice(
        title: "Evidenz",
        definition: "Eine konkretisierende Häufung, bei welcher der eigentliche Hauptgedanke in mehrere als Aufzählung erscheinende Teilgedanken getrennt wird, die den Hauptgedanken aufgreifen und im Detail ausführen.",
        example: "„Seine Augen suchten einen Menschen – und ein Grauen erweckendes Scheusal kroch aus einem Winkel ihm entgegen, der mehr dem Lager eines wilden Thieres als dem Wohnort eines menschlichen Geschöpfes glich. Ein blasses todtenähnliches Gerippe, alle Farben des Lebens aus einem Angesicht verschwunden, in welches Gram und Verzweiflung tiefe Furchen gerissen hatten, Bart und Nägel durch eine so lange Vernachlässigung bis zum Scheußlichen gewachsen, vom langen Gebrauche die Kleidung halb vermodert und aus gänzlichem Mangel der Reinigung die Luft um ihn verpestet – so fand er diesen Liebling des Glücks, […]“ (Friedrich Schiller)",
        wikipedia: "http://de.wikipedia.org/wiki/Evidenz")

    static let exclamatio = StylisticDevice(
        title: "Exclamatio",
        definition: "Ein Ausruf!",
        example: "„Stirb!“\n„Hilfe!“\n„Mörder!“\n„Au!“",
        wikipedia: "http://de.wikipedia.org/wiki/Exclamatio")

    static let exemplum = StylisticDevice(
        title: "Exemplum",
        definition: "Beispiel, das einen konkreten Sachverhalt verdeutlicht.",
        example: "„Hierzu werfen wir einen Blick in unsere Geschichte. Die Zeit der Weimarer Republik zeigt beispielhaft auf, warum das Recht des Parlaments auf Selbstauflösung in unserem Grundgesetz nicht vorhanden ist.“",
        wikipedia: "http://de.wikipedia.org/wiki/Exemplum")

    
    
    // F
    
    static let floskel = StylisticDevice(
        title: "Floskel",
        definition: "Eine oberflächliche, meist banale Bemerkung.",
        example: "„Ein Mann muss tun, was ein Mann tun muss.“",
        wikipedia: "http://de.wikipedia.org/wiki/Floskel")

    
    
    // G
    
    static let geminatio = StylisticDevice(
        title: "Geminatio",
        definition: "Eine Verdoppelung. (Sonderfall der Repetitio)",
        example: "„Diese, diese Unverschämtheit!“",
        wikipedia: "http://de.wikipedia.org/wiki/Geminatio")

    
    static let gleichnis = StylisticDevice(
        title: "Gleichnis",
        definition: "Eine konkrete, bildhafte Veranschaulichung eines Sachverhalts mittels eines durch sprachliche Kontinuation ausgebauten Vergleichs.",
        example: "(Bibel: Lukas 15,1-10: „Verlorenes Schaf“)",
        wikipedia: "http://de.wikipedia.org/wiki/Gleichnis")

    
    
    
    // H
    
    static let hendiadyoin = StylisticDevice(
        title: "Hendiadyoin",
        definition: "Die syntaktische Beiordnung eines semantisch untergeordneten Begriffs.",
        example: "„Um ihn muhen hundert Herden und sizilische Kühe.“ (Horaz)",
        wikipedia: "http://de.wikipedia.org/wiki/Hendiadyoin")

    
    static let homoioteleuton = StylisticDevice(
        title: "Homoioteleuton",
        definition: "Eine Endgleichheit im Reim. (Gegensatz: Homoioarkton)",
        example: "„[...] und verschlang die kleine fade Made ohne Gnade. Schade!“ (Heinz Erhardt: Die Made)",
        wikipedia: "http://de.wikipedia.org/wiki/Homoioteleuton")

    
    static let homoioarkton = StylisticDevice(
        title: "Homoioarkton",
        definition: "Eine Anfangsgleichheit im Reim. (Gegensatz: Homoioteleuton)",
        example: "„Billionen böse Buben beobachten Boris Becker beim Bechern.“\n„Milch macht müde Männer munter.“")

    
    static let hypallage = StylisticDevice(
        title: "Hypallage",
        definition: "Die Zuordnung eines Attributs zum falschen Substantiv.",
        example: "„das blaue Lächeln seiner Augen“\n„Dunkel gingen sie durch die schweigende Nacht.“ (Vergil)",
        synonym: "Enallage",
        wikipedia: "http://de.wikipedia.org/wiki/Hypallage")

    
    static let hyperbaton = StylisticDevice(
        title: "Hyperbaton",
        definition: "Ein Einschub durch Umstellung; zwei syntaktisch (und inhaltlich) zusammengehörende Wörter stehen weit voneinander entfernt.",
        example: "„‚Hier‘, rief er, ‚bin ich‘“\n„Der Kragenbär / der holt sich / munter / einen nach / dem andern / runter.“ (Robert Gernhardt)",
        wikipedia: "http://de.wikipedia.org/wiki/Hyperbaton")

    
    static let hyperbel = StylisticDevice(
        title: "Hyperbel",
        definition: "Eine starke Übertreibung.",
        example: "„todmüde“\n„fuchsteufelswild“\n„Schneckentempo“",
        wikipedia: "http://de.wikipedia.org/wiki/Hyperbel_(Sprache)")
    
    
    static let hypotaxe = StylisticDevice(
        title: "Hypotaxe",
        definition: "Unterordnung von Nebensätzen unter einen verschachtelten, höherrangigen Teilsatz. (Gegenteil: Parataxe)",
        example: "„Als sie nach einer langen Konferenz, als es draußen bereits dunkel wurde, nach Hause fuhr, warf sie einen Blick in die glitzernde Metropole.“",
        wikipedia: "http://de.wikipedia.org/wiki/Hypotaxe")

    
    static let hysteron_proteron = StylisticDevice(
        title: "Hysteron-Proteron",
        definition: "Nachholtechnik; das logisch/zeitlich Nachfolgende wird an den Anfang gestellt. (Sonderfall: Anachronismus)",
        example: "„Dein Mann ist tot und lässt dich grüßen!“ (Goethe: Faust I: Mephisto an Marthe)")

    

    // I
    
    static let imperativ = StylisticDevice(
        title: "Imperativ",
        definition: "Eine Aufforderung oder ein Befehl.",
        example: "„Geh!“\n„Stehen bleiben!“\n„Wer Ohren hat zu hören, der höre!“",
        wikipedia: "http://de.wikipedia.org/wiki/Imperativ_(Modus)")

    
    static let inkonzinnität = StylisticDevice(
        title: "Inkonzinnität",
        definition: "Eine bewusste Vermeidung von Parallelem in Syntax, Wortwahl und Tempora.",
        example: "„Germanien ist von den Sarmaten und Dakern durch gegenseitige Furcht und Berge getrennt.“ (Tacitus: Germania I)")

    
    static let interjektion = StylisticDevice(
        title: "Interjektion",
        definition: "Ein Ausruf. (meist Gefühlsausdruck)",
        example: "„Ah!“, „Igitt!“",
        wikipedia: "http://de.wikipedia.org/wiki/Interjektion")

    
    static let inversion = StylisticDevice(
        title: "Inversion",
        definition: "Eine Umkehrung der normalen Wortstellung zur Hervorhebung des Umgestellten.",
        example: "„Ein Dieb ist er!“ statt: „Er ist ein Dieb!“",
        wikipedia: "http://de.wikipedia.org/wiki/Inversion_(Sprache)")

    
    static let invokation = StylisticDevice(
        title: "Invokation",
        definition: "Eine feierliche Anrufung (oft einer höheren Macht).",
        example: "„Gott sei mein Zeuge!“",
        wikipedia: "http://de.wikipedia.org/wiki/Invokation")

    
    static let ironie = StylisticDevice(
        title: "Ironie",
        definition: "Eine Divergenz (oftmals Gegensatz) von wörtlicher und wirklicher Bedeutung.",
        example: "„Schöne Bescherung!“\n„Das hast du ja mal wieder toll gemacht!“",
        wikipedia: "http://de.wikipedia.org/wiki/Ironie")

    

    // K
    
    static let kakophonie = StylisticDevice(
        title: "Kakophonie",
        definition: "Ein als unangenehm oder unästhetisch empfundener Laut, Klang oder Wortfolge, der schlecht auszusprechen ist.",
        example: "„Rex Xerxes“",
        wikipedia: "http://de.wikipedia.org/wiki/Kakophonie")

    
    static let katachrese = StylisticDevice(
        title: "Katachrese",
        definition: "1) Eine Metapher als Ersatz für ein fehlendes Wort. (z.B. bei technischen Neuerungen)\n2) Ein Bildbruch, Bildmissbrauch, oder eine falsche Verbindung zweier Bilder.",
        example: "1) „der Arm eines Flusses“, „der Arm eines Gerätes“\n2) „Das schlägt dem Fass die Krone ins Gesicht.“\n„Der Zahn der Zeit, der schon so viele Tränen getrocknet hat, wird auch Gras über diese Wunde wachsen lassen.“",
        wikipedia: "http://de.wikipedia.org/wiki/Katachrese")

    
    static let klimax = StylisticDevice(
        title: "Klimax",
        definition: "Eine Stufenweise Steigerung von Wörtern. (Gegenteil zur Antiklimax)",
        example: "„Sie arbeiten zehn, zwölf, ja vierzehn Stunden täglich am Erfolg.“",
        wikipedia: "http://de.wikipedia.org/wiki/Klimax_(Sprache)")

    
    static let kyklos = StylisticDevice(
        title: "Kyklos",
        definition: "Sonderfall der Repetitio, Wiederholung des Satz-/Versanfangs am Ende. (Schema: x … x)",
        example: "„Entbehren sollst du, sollst entbehren.“ (Goethe)",
        wikipedia: "http://de.wikipedia.org/wiki/Kyklos")

    
    
    // L
    
    static let litotes = StylisticDevice(
        title: "Litotes",
        definition: "Eine Hervorhebung eines Begriffs durch Untertreibung, Abschwächung oder doppelte Verneinung.",
        example: "„meine Wenigkeit“\n„nicht wenig verdienen“ (Sonderfall Negation)\n„ich hasse dich nicht.“ statt: „ich liebe dich.“",
        wikipedia: "http://de.wikipedia.org/wiki/Litotes")

    
    
    // M
    
    static let metapher = StylisticDevice(
        title: "Metapher",
        definition: "Ersatz durch bildlichen Ausdruck, bei dem mindestens eine besondere Eigenschaft verbindend wirkt.",
        example: "„Deckmantel einer Feigheit“\n„Am Fuße des Berges“\n„ein Meer von Menschen“",
        wikipedia: "http://de.wikipedia.org/wiki/Metapher")

    
    static let metonymie = StylisticDevice(
        title: "Metonymie",
        definition: "Ersatz eines Begriffs durch einen bildlichen Ausdruck mit realer Beziehung. (Ursache/Wirkung, Rohstoff/Produkt, Gefäß/Inhalt, ...)",
        example: "„Schiller lesen“\n„das Eisen“ für: „das Schwert“\n„ein Glas trinken“\n„einen Teller aufessen“",
        wikipedia: "http://de.wikipedia.org/wiki/Metonymie")

    
    static let montage = StylisticDevice(
        title: "Montage",
        definition: "Ein Ineinanderverschieben verschiedener Sprach- und/oder Inhaltsebenen.",
        example: "„Aus „Euro“ und „teuer“ wird „Teuro“\n„kaufgepasst“",
        wikipedia: "http://de.wikipedia.org/wiki/Montage_(Literatur)")

    
    
    // N
    
    static let neologismus = StylisticDevice(
        title: "Neologismus",
        definition: "Eine Wortneuschöpfung.",
        example: "Selberlebensbeschreibung (Jean Paul)\nKnabenmorgenblütenträume (Goethe)\nknorke",
        wikipedia: "http://de.wikipedia.org/wiki/Neologismus")

    
    
    // O
    
    static let onomatopoesie = StylisticDevice(
        title: "Onomatopoesie",
        definition: "Die sprachliche Nachahmung von außersprachlichen, akustischen Phänomenen.",
        example: "„Quak!“, „Kuckuck!“, „Muh!“, „Bumm!“, „Peng!“, „Zisch!, „Es knistert und knastert“, „schnattattattattern“",
        synonym: "Lautmalerei",
        wikipedia: "http://de.wikipedia.org/wiki/Onomatopoesie")
    
    static let oxymoron = StylisticDevice(
        title: "Oxymoron",
        definition: "Ein innerer Widerspruch (Sonderfall: Contradictio in adjecto)",
        example: "„heißkalt“, „bittersüß“, „Flüssiggas“, „hübschhässlich“, „Hassliebe“, „großer Zwerg“, „beredtes Schweigen“ (Cicero)",
        wikipedia: "http://de.wikipedia.org/wiki/Oxymoron")

    
    
    // P
    
    static let palindrom = StylisticDevice(
        title: "Palindrom",
        definition: "Wörter oder Sätze, welche von vorn und hinten gelesen Sinn ergeben.",
        example: "„Noch war und tat ich nichts; aber wenn noch das Leben ein leerer Nebel ist, kannst du ihn übersteigen, oder festgreifen und zerschlagen?“ (Jean Paul: Titan)",
        wikipedia: "http://de.wikipedia.org/wiki/Palindrom")

    
    static let paradoxon = StylisticDevice(
        title: "Paradoxon",
        definition: "Eine scheinbare Widersprüchlichkeit oder Formulierung einer Idee, die der vorherrschenden Meinung widerspricht.",
        example: "„Der Entwurf ist teuflisch, aber wahrlich – göttlich“ (zugleich Antithese)\n„Die Verbrechen bringen unermessliche Wohltaten hervor und die größten Tugenden entwickeln unheilvolle Konsequenzen.“ (Paul Valéry), „Ich weiß, dass ich nichts weiß.“ (Sokrates)",
        wikipedia: "http://de.wikipedia.org/wiki/Paradoxon")


    static let paralipse = StylisticDevice(
        title: "Paralipse",
        definition: "Eine vorgebliche Auslassung: Der Autor täuscht vor, etwas auszulassen, auf das er in Wirklichkeit fest besteht.",
        example: "„Ganz zu schweigen davon, dass Caesar auch in Gallien …“\n„Ich werde Ihnen nicht die Schande bereiten, Sie daran zu erinnern, dass …“",
        synonym: "Praeteritio",
        wikipedia: "http://de.wikipedia.org/wiki/Paralipse")

    
    static let parallelismus = StylisticDevice(
        title: "Parallelismus",
        definition: "Ein paralleler Aufbau von (Teil-)Sätzen.",
        example: "„Vogel fliegt, Fisch schwimmt, Mensch läuft.“ (Emil Zátopek)",
        wikipedia: "http://de.wikipedia.org/wiki/Parallelismus_(Rhetorik)")


    static let paraphrase = StylisticDevice(
        title: "Paraphrase",
        definition: "Eine zusätzliche, erklärende Umschreibung.",
        example: "„Fische, die stummen Meeresbewohner“",
        wikipedia: "http://de.wikipedia.org/wiki/Paraphrase_(Sprache)")

    
    static let parataxe = StylisticDevice(
        title: "Parataxe",
        definition: "Das Nebeneinanderstellen gleichwertiger Hauptsätze bzw. beigeordneter Nebensätze.",
        example: "„Hier stehe ich, ich kann nicht anders. Gott helfe mir! Amen!“ (Luther)",
        wikipedia: "http://de.wikipedia.org/wiki/Parataxe")

    
    static let parenthese = StylisticDevice(
        title: "Parenthese",
        definition: "Ein Einschub von Wörtern oder Satzteilen im Satz.",
        example: "„Das ist – wie gesagt – unwichtig.“",
        wikipedia: "http://de.wikipedia.org/wiki/Parenthese")

    
    static let paronomasie = StylisticDevice(
        title: "Paronomasie",
        definition: "Die Verbindung von zwei ähnlich klingenden, in der Bedeutung unterschiedlichen Begriffen. (Sonderfall eines Wortspiels)",
        example: "„Wer rastet, der rostet.“\n„Lieber arm dran als Arm ab.“\nBistümer, Wüsttümer\nWelton, Hellton",
        synonym: "Annominatio",
        wikipedia: "http://de.wikipedia.org/wiki/Paronomasie")
    

    static let pars_pro_toto = StylisticDevice(
        title: "Pars pro toto",
        definition: "Eine Benennung durch einen Teil. (Sonderfall der Synekdoche)",
        example: "„pro Kopf“ für: „pro Person“\n„Ein Dach über dem Kopf haben“",
        wikipedia: "http://de.wikipedia.org/wiki/pars_pro_toto")

    
    static let periphrase = StylisticDevice(
        title: "Periphrase",
        definition: "Die Umschreibung eines Begriffs durch Einzelmerkmale.",
        example: "„der Vater des Wirtschaftswunders“, umschreibt Ludwig Erhard",
        wikipedia: "http://de.wikipedia.org/wiki/Periphrase")


    static let personifikation = StylisticDevice(
        title: "Personifikation",
        definition: "Zuweisung menschlicher Eigenschaften an Tiere, Gegenstände oder ähnliches.",
        example: "„Die Sonne lacht“\n„Stimme des Gewissens“\n„Mutter Erde“\n„Vater Staat“\n„Der Wind spielt“",
        wikipedia: "http://de.wikipedia.org/wiki/Personifikation")

    
    static let pleonasmus = StylisticDevice(
        title: "Pleonasmus",
        definition: "Häufung sinngleicher, in der Wortart verschiedener Wörter, die beide die Bedeutung des Gesamtbegriffs beinhalten.",
        example: "„weißer Schimmel“, „runde Kugel“, „alter Greis“",
        wikipedia: "http://de.wikipedia.org/wiki/Pleonasmus")

    
    static let pluralis_auctoris = StylisticDevice(
        title: "Pluralis Auctoris",
        definition: "Die Verwendung des Plural anstelle des Singular zur generalisierung oder deklarierung als Gemeinschaftswerk. (meist in Wissenschaftlichen Arbeiten)",
        example: "„Wir kommen damit zum Kern des Problems...“",
        wikipedia: "http://de.wikipedia.org/wiki/pluralis_auctoris")


    static let pluralis_majestatis = StylisticDevice(
        title: "Pluralis Majestatis",
        definition: "Die Verwendung des Plural für die eigene Person als Ausdruck von Macht; ursprünglich bei Adel und Würdenträgern.",
        example: "„Wir, Benedictus PP. XVI im 1. Jahr Unseres Pontifikates …“",
        wikipedia: "http://de.wikipedia.org/wiki/pluralis_majestatis")

    
    static let pluralis_modestiae = StylisticDevice(
        title: "Pluralis Modestiae",
        definition: "Die Verwendung des Plural anstelle des Singular zum Ausdruck von Bescheidenheit.",
        example: "„Wir haben es geschafft.“ statt: „Ich habe es geschafft.“",
        wikipedia: "http://de.wikipedia.org/wiki/pluralis_modestiae")


    static let pointe = StylisticDevice(
        title: "Pointe",
        definition: "Eine unerwartete Zuspitzung.",
        example: "„Wenn einer, der mit Mühe kaum /\nGekrochen ist auf einen Baum, /\nSchon meint, dass er ein Vogel wär, /\nSo irrt sich der.“ (Wilhelm Busch, Der fliegende Frosch)",
        wikipedia: "http://de.wikipedia.org/wiki/Pointe")

    
    static let polyptoton = StylisticDevice(
        title: "Polyptoton",
        definition: "Die Wiederholung eines Wortes in verschiedenen Beugungsformen.",
        example: "„Lupus est homo homini.“ („Der Mensch ist des Menschen Wolf.“) (Plautus: Asinaria)",
        wikipedia: "http://de.wikipedia.org/wiki/Polyptoton")


    static let polysyndeton = StylisticDevice(
        title: "Polysyndeton",
        definition: "Eine Mehrfach verbundene Reihung. (häufige Bindewörter: „und“, „oder“)",
        example: "„Einigkeit und Recht und Freiheit“ (Hoffmann von Fallersleben: Lied der Deutschen)",
        wikipedia: "http://de.wikipedia.org/wiki/Polysyndeton")

    
    static let prokatalepsis = StylisticDevice(
        title: "Prokatalepsis",
        definition: "Eine Vorwegnahme. (z.B. eines möglichen Einwandes)",
        example: "„Natürlich könnte man hier einwenden, dass …“",
        wikipedia: "http://de.wikipedia.org/wiki/Prokatalepsis")


    
    // R
    
    static let redundanz = StylisticDevice(
        title: "Redundanz",
        definition: "Eine Informationsdopplung.",
        example: "„‚Bei der Schlußfeier der XVI. Olympischen Sommerspiele schickten die australischen Salutschützen dem Muskelkrieg von Melbourne ein martialisches Echo nach. Die Artilleristen Ihrer Majestät der englischen Königin lieferten den aktuellen kriegerischen Kulissendonner zu jenem olympischen Schauspiel, das inmitten einer sehr unfriedlichen Welt zum schlechten Stück geworden war. Sie kanonierten die wie einen Zylinderhut aufgestülpte Schlußfeier-Stimmung und alle preisenden Reden von der Gleichheit und Brüderlichkeit unter Sportsleuten zu eitel Schall und Rauch.‘ […] Versucht man, das Zitat aus seiner Zeitschrift ins Deutsche zurück zu übersetzen, so ergeben sich zwei Sätze, die in der Tat knapp sind: ‚Bei der Schlußfeier der Olympiade wurde Salut geschossen. Das hat uns mißfallen.‘“ (Hans Magnus Enzensberger)\n„Bei Dämmerung gehen die Straßenlaternen abends an und beleuchten die Straßen, wenn es dunkel wird.“",
        wikipedia: "http://de.wikipedia.org/wiki/Redundanz_(Kommunikationstheorie)")


    static let repetitio = StylisticDevice(
        title: "Repetitio",
        definition: "Die Wiederholung eines Wortes/Satzteils.",
        example: "„er gab und gab und gab et dar“ (Konrad von Würzburg)\n„bald da, bald dort“",
        wikipedia: "http://de.wikipedia.org/wiki/Repetitio")


    static let rhetorische_frage = StylisticDevice(
        title: "Rhetorische Frage",
        definition: "Eine Frage, auf die keine Antwort erwartet wird.",
        example: "„Was ist schon normal?“\n„Seh’ ich so blöd aus?“\n„Wo sind wir denn hier?“",
        synonym: "Scheinfrage",
        wikipedia: "http://de.wikipedia.org/wiki/Rhetorische_Frage")


    
    // S
    
    static let sarkasmus = StylisticDevice(
        title: "Sarkasmus",
        definition: "Ein beißender, bitterer und/oder verstatic letzender Spott und Hohn. Oftmals wird dieser unter Hilfe von Ironie angewand.",
        example: "Der Geschlagene ruft, anstelle zu weinen: „Natürlich! Gleich noch mal!“",
        wikipedia: "http://de.wikipedia.org/wiki/Sarkasmus")


    static let scheindefinition = StylisticDevice(
        title: "Scheindefinition",
        definition: "Gibt vor, etwas allgemeingültig zu erklären, ist aber nur die Meinung des Sprechers.",
        example: "„Purex ist Geschmack.“\n„Nacht ist, wenn kein Sonnenlicht mehr auf die Erde trifft.“")


    static let sentenz = StylisticDevice(
        title: "Sentenz",
        definition: "Ein knapper, treffend formulierter Sinnspruch, der einen Satz zusammenfasst und zu allgemeiner Bedeutung erhebt.",
        example: "„Die Axt im Haus erspart den Zimmermann“ (Friedrich Schiller: Wilhelm Tell)",
        wikipedia: "http://de.wikipedia.org/wiki/Sentenz")


    static let solözismus = StylisticDevice(
        title: "Solözismus",
        definition: "Ein grober sprachlicher Fehler. (oftmals in der syntaktischen Verbindung der Wörter)",
        example: "„Wo du wolle?“\n„Hier werden Sie geholfen.“\n„Angst essen Seele auf“ (R. W. Fassbinder)"
        // wikipedia: "http://de.wikipedia.org/wiki/Solözismus"
    )


    static let stabreim = StylisticDevice(
        title: "Stabreim",
        definition: "Aufeinanderfolgende oder nah beieinander stehende Wörter ähneln sich in der ersten Silbe.",
        example: "„Fischers Fritze fischt frische Fische“\n„Wiegende Welle auf wogender See“",
        wikipedia: "http://de.wikipedia.org/wiki/Stabreim")


    static let stichomythie = StylisticDevice(
        title: "Stichomythie",
        definition: "Eine schnelle Wechselrede mit Rednerwechsel von Vers zu Vers mit wenigen Worten.",
        example: "Dialog zwischen Iphigenie und Arkas in Iphigenie auf Tauris (J. W. v. Goethe): „Iphigenie: ‚Wie's der Vertriebnen, der Verwaisten ziemt.‘/ ,Arkas: Scheinst du dir hier vertrieben und verwaist?‘/ Iphigenie: ,Kann uns zum Vaterland die Fremde werden?‘/ Arkas: ,Und dir ist fremd das Vaterland geworden.‘“",
        wikipedia: "http://de.wikipedia.org/wiki/Stichomythie")


    static let sustentio = StylisticDevice(
        title: "Sustentio",
        definition: "Das Auslösen von Überraschung beim Zuhörer durch Nichtbefriedigung einer Erwartungshaltung.",
        example: "„Selbsterkenntnis ist der beste Weg zur Verstellung.“\n„Milch ist ein starkes Getränk.“",
        wikipedia: "http://de.wikipedia.org/wiki/Sustentio")


    static let syllepse = StylisticDevice(
        title: "Syllepse",
        definition: "Ein nur einmal gesetztes Satzteil gehört mehreren Satzgliedern oder Wörtern in verschiedenen grammatischen Formen oder verschiedenem Sinn an. Es muss in den ausgelassenen Fällen sinngemäß in modifizierter Form ergänzt werden.",
        example: "„Was heißt und zu welchem Ende studiert man Universalgeschichte?“ (Schiller)\n„Die Augen des Herrn sehen auf die Gerechten und seine Ohren auf ihr Schreien.“ (Psalm 34 (Luther))",
        wikipedia: "http://de.wikipedia.org/wiki/Syllepse")
    

    static let symbol = StylisticDevice(
        title: "Symbol",
        definition: "Ein Bild, das auf eine abstrakte Vorstellung verweist.",
        example: "„weiße Taube“ für: „Frieden“\n„rotes Herz“ für: „Liebe“",
        wikipedia: "http://de.wikipedia.org/wiki/Symbol")


    static let synästhesie = StylisticDevice(
        title: "Synästhesie",
        definition: "„Eine Verbindung verschiedener Sinneseindrücke.",
        example: "„Das nasse Gras klang wie ein Liebeslied“\n„Süßer die Glocken nie klingen“"
        // wikipedia: "http://de.wikipedia.org/wiki/Synästhesie"
    )

    
    static let synekdoche = StylisticDevice(
        title: "Synekdoche",
        definition: "Ersetzung durch numerisch verwandten Begriff. (Teil/Ganzes, Gattung/Art, Singular/Plural, Früheres/Späteres, ...)",
        example: "„Dach über'm Kopf haben“ für: „in einem/-r Haus/Wohnung leben“\n„Kopf“ für: „Person/Mensch“\n„der Deutsche“ für: „viele Deutsche“",
        wikipedia: "http://de.wikipedia.org/wiki/Synekdoche")

    
    static let synonym = StylisticDevice(
        title: "Synonym",
        definition: "Die Ersetzung eines Wortes durch ein ihm gleichbedeutendes.",
        example: "Hund, Köter, Kläffer",
        wikipedia: "http://de.wikipedia.org/wiki/Synonym")

    
    
    // T
    
    static let tautologie = StylisticDevice(
        title: "Tautologie",
        definition: "Eine Wiederholung des Gesagten durch ein sinnverwandtes Wort, bei der beide Wörter derselben Wortart angehören.",
        example: "„hegen und pflegen“\n„immer und ewig“\n„Angst und Bange“\n„Not und Elend“\n„List und Tücke“",
        wikipedia: "http://de.wikipedia.org/wiki/Tautologie_(Sprache)")
    
    
    static let Tetrakolon = StylisticDevice(
        title: "Tetrakolon",
        definition: "Viergliedriger Ausdruck, bei dem alle vier Teile semantisch gleich aufgebaut sind und zueinander parallel und/oder chiastisch stehen.",
        example: "„dare, donare, dicare, consecrare“ (Cicero) („ihm geben, ihm schenken, ihm widmen, ihm darbringen“)",
        wikipedia: "http://de.wikipedia.org/wiki/Tetrakolon")

    
    static let totemismus = StylisticDevice(
        title: "Totemismus",
        definition: "Ein Mensch oder eine menschliche Eigenschaft erhält tierische Eigenschaften. Im Bereich prähistorischer Religionen zum Beispiel Mischwesen aus Mensch und Tieren. (Gegenteil: Anthropomorphismus)",
        example: "„Da sprach der König: ‚Wenn ich nur wüsste, was dich vergnügt machen könnte. Willst du meine schöne Tochter zur Frau?‘ ‚Ach ja‘, sagte das Eselein, war auf einmal ganz lustig und guter Dinge, denn das war es gerade, was es sich gewünscht hatte. Also ward eine grosse und prächtige Hochzeit gehalten.“",
        wikipedia: "http://de.wikipedia.org/wiki/Totemismus")

    
    static let totum_pro_parte = StylisticDevice(
        title: "Totum pro parte",
        definition: "Etwas wird durch den Oberbegriff seines Bedeutungsfeldes ausgedrückt. (Sonderfall der Synekdoche)",
        example: "„Wald“ für: „Baum“\n„Deutschland gewinnt“ statt: „der deutsche Sportler gewinnt“",
        wikipedia: "http://de.wikipedia.org/wiki/totum_pro_parte")

    
    static let trikolon = StylisticDevice(
        title: "Trikolon",
        definition: "Ein dreigliedriger Ausdruck, bei dem alle drei Teile semantisch gleich aufgebaut sind und zueinander parallel und/oder chiastisch stehen.",
        example: "„Veni, vidi, vici“\n„quadratisch, praktisch, gut“",
        wikipedia: "http://de.wikipedia.org/wiki/Trikolon")

    
    static let tricolon_in_membris_crescentibus = StylisticDevice(
        title: "Tricolon in membris crescentibus",
        definition: "Ein dreigliedriger Ausdruck in Verbindung mit einer inhaltlichen oder syntaktischen Steigerung. (dreiteiliger Klimax)",
        example: "„Ich achte, liebe, vergöttere dich“",
        wikipedia: "http://de.wikipedia.org/wiki/tricolon_in_membris_crescentibus")

    
    
    // U
    
    static let untertreibung = StylisticDevice(
        title: "Untertreibung",
        definition: "Die Abschwächung einer Aussage.",
        example: "„ganz gut“ statt: „hervorragend“",
        wikipedia: "http://de.wikipedia.org/wiki/Untertreibung")

    
    
    // V
    
    static let variatio = StylisticDevice(
        title: "Variatio",
        definition: "Eine Gleichklangs-/Wiederholungsvermeidung.",
        example: "„Die gebürtige Münchenerin verbrachte ihre Jugend in der Bayernmetropole und kehrte im Alter in die weißblaue Landeshauptstadt zurück.“",
        wikipedia: "http://de.wikipedia.org/wiki/Variatio")

    
    static let verdinglichung = StylisticDevice(
        title: "Verdinglichung",
        definition: "Die Zuordnung nichtmenschlicher Eigenschaften zu Personen.",
        example: "„Die Dachdecker brechen entzwei“\n„Bayern München hat wieder Spielermaterial zugekauft“")

    
    static let vergleich = StylisticDevice(
        title: "Vergleich",
        definition: "Eine durch ein Vergleichswort gekennzeichnete Veranschaulichung.",
        example: "„stark wie ein Löwe“\n„größer als ein Elefant“",
        wikipedia: "http://de.wikipedia.org/wiki/Vergleich_(Literatur)")

    
    static let vulgarismus = StylisticDevice(
        title: "Vulgarismus",
        definition: "Eine derbe oder ordinäre Ausdrucksweise.",
        example: "„kacken“, „pisswarm“",
        wikipedia: "http://de.wikipedia.org/wiki/Vulgarismus_(Sprache)")

    
    
    // W
    
    static let wortspiel = StylisticDevice(
        title: "Wortspiel",
        definition: "1) Die Verwendung des gleichen oder eines vom gleichen Wortstamm abgeleiteten Wortes in verschiedenen Bedeutungen oder verschiedenen Sinnzusammenhängen \n2) Eine leichte Veränderung des Wortes, durch die dieses eine Zusatzbedeutung erhält.",
        example: "„Jesuiter – Jesuwider“\n„Unbiegsam sei sein Wille, aber biegsam sein Rücken“",
        wikipedia: "http://de.wikipedia.org/wiki/Wortspiel")

    
    
    // Z
    
    static let zeugma = StylisticDevice(
        title: "Zeugma",
        definition: "Eine syntaktisch korrekte Verbindung semantisch nicht zusammengehöriger Satzglieder.",
        example: "„Er hob den Blick und ein Bein gen Himmel.“\n„Er öffnete die Schachtel, danach den Mund.“\n„Er saß ganze Nächte und Sessel durch“\n„Ich heiße Heinz Erhardt und Sie willkommen“",
        wikipedia: "http://de.wikipedia.org/wiki/Zeugma")

    
    static let zynismus = StylisticDevice(
        title: "Zynismus",
        definition: "Eine boshaft verletzende, oft ironische Äußerung als Demonstration der Überlegenheit unter Missachtung, Umdeutung oder Ad-absurdum-Führung allgemein verbreiteter oder anerkannter Werte.",
        example: "„Der Schläger sagt nach seiner Tat: ‚Hat es dir gefallen? Soll ich noch mal draufhauen?‘“\n„Jedes Volk hat die Regierung, die es verdient“",
        wikipedia: "http://de.wikipedia.org/wiki/Zynismus")

        
}