import QtQuick 2.0
import MuseScore 1.0
import FileIO 1.0


MuseScore {
    menuPath:    "Plugins.ScanScore"
    version:     "1.0"
    description: qsTr("This demo plugin traverses a score by measure-->staff")

    FileIO {
        id: outfile
        onError: console.log(msg)
    }

    property string toWrite: ""
    property int chordCount: 0

    function getElementInformation(element) {
        var cursor = curScore.newCursor();
        for (var staff = 0; staff <= 4; staff++) {
            for (var voice = 0; voice < 4; voice++) {
                cursor.voice = voice;
                cursor.staffIdx = staff;
                cursor.rewind(0);
                while (cursor.segment) {
                    if (cursor.element === element) {
                        var note = cursor.element;
                        var measurex = cursor.measure.pagePos.x.toPrecision(8);
                        var notex = note.pagePos.x.toPrecision(8);
                        var defaultx = (notex - measurex) * 10
                        return new Array(cursor.staffIdx, defaultx.toFixed(2))
                    }
                    cursor.next();
                }
            }
        }
    }

    function processChord(chord) {
        console.log("chord.notes.length=" + chord.notes.length);
        for (var i=0; i<chord.notes.length; i++) {
            processNote(chord.notes[i]);
        }
    }

    function processMeasure(measure, staff) {
        var segment = measure.firstSegment
        while (segment) {
            for (var track = 0; track <= curScore.ntracks; track++) {
                var element = segment.elementAt(track);
                if(element){
                    if (element.type === Element.CHORD || element.type === Element.REST){
                        var information = getElementInformation(element)
                        if (information[0] === staff){
                            console.log("element: " + element)
                            console.log(" x:" + information[1])
                            toWrite += information[1] + "\n"
                            if (element.type === Element.CHORD){
                                chordCount += 1;
                            }
                        }
                    }
                }
            }
            segment = segment.nextInMeasure
        }
    }

    onRun: {
        if (typeof curScore === 'undefined')
            Qt.quit();
        var score = curScore
        console.log(score.name)
        outfile.source = "/Users/lisimin/Desktop/xml/Project/" + score.name + ".txt"
        var measure = score.firstMeasure
        var measureNumber = 1;
        while (measure) {
            for (var staff = 0; staff <= 1; staff++) {
                console.log("Measure:" + measureNumber + " Staff:" + (staff+1))
                processMeasure(measure, staff)
                console.log("----------------------------------")
            }
            measure = measure.nextMeasure
            measureNumber++;
        }
        console.log(chordCount)
        outfile.write(toWrite)
        Qt.quit()
    }
}
