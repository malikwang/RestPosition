import QtQuick 2.0
import MuseScore 1.0
import FileIO 1.0

MuseScore {
    version: "1.0"
    description: "Save Rest Position"
    menuPath: "Plugins.RestPosition"
    FileIO {
        id: outfile
        onError: console.log(msg)
    }
    function saveNotePosition() {
        var cursor = curScore.newCursor();
        cursor.rewind(1);
        var startStaff;
        var endStaff;
        var endTick;
        var toWrite = "";
        var fullScore = false;
        outfile.source = "/Users/lisimin/Desktop/xml/" + cursor.score.title + ".txt"
        if (!cursor.segment) { // no selection
            fullScore = true;
            startStaff = 0; // start with 1st staff
            endStaff = curScore.nstaves - 1; // and end with last
        } else {
            startStaff = cursor.staffIdx;
            cursor.rewind(2);
            if (cursor.tick === 0) {
                endTick = curScore.lastSegment.tick + 1;
            } else {
                endTick = cursor.tick;
            }
            endStaff = cursor.staffIdx;
        }
        for (var staff = startStaff; staff <= endStaff; staff++) {
            for (var voice = 0; voice < 4; voice++) {
                cursor.rewind(1); // sets voice to 0
                cursor.voice = voice; //voice has to be set after goTo
                cursor.staffIdx = staff;
                
                if (fullScore)
                    cursor.rewind(0) // if no selection, beginning of score

                while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                    if (cursor.element && cursor.element.type === Element.REST) {
                        var rest = cursor.element;
                        var measurex = cursor.measure.pagePos.x.toPrecision(8);
                        var restx = rest.pagePos.x.toPrecision(8);
                        var defaultx = (restx - measurex) * 10
                        toWrite += "staff:" + staff +" voice:" + voice + " x:" + defaultx.toFixed(2) + "\n";
                        console.log( "staff:" + staff +" voice:" + voice + " x:" + defaultx.toFixed(2));
                    }
                    cursor.next();
                }
            }
        }
        outfile.write(toWrite);
    }
    onRun: {
        if (typeof curScore === 'undefined')
            Qt.quit();
        saveNotePosition()
        Qt.quit();
    }
}
