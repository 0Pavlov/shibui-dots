import QtQuick
import QtQuick.Shapes

Item {
    id: root

    required property vector2d start
    required property vector2d end

    property double segmentCount: 10
    property double segmentLen: 30

    property alias color: path.strokeColor

    readonly property double gravity: 5000
    readonly property int constraintRunCount: 40

    readonly property Component p: PathLine {
        property vector2d pos
        property vector2d prevPos: pos
        property vector2d acc
        x: pos.x
        y: pos.y
    }

    Shape {
        id: shape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            id: path
            capStyle: ShapePath.RoundCap
            strokeColor: "#C19A6B"
            strokeWidth: 6
            fillColor: "transparent"
        }
    }

    Component.onCompleted: () => {
        const xInc = (end.x - start.x) / segmentCount;
        const yInc = (end.y - start.y) / segmentCount;
        let i = 0;
        while (i < segmentCount) {
            path.pathElements.push(p.createObject(root, {
                pos: start.plus(Qt.vector2d(xInc * i, yInc * i)),
                acc: Qt.vector2d(0, root.gravity)
            }));
            i++;
        }
        
        path.pathElements[0].acc.y = 0;
        path.pathElements[segmentCount - 1].acc.y = 0;
    }

    FrameAnimation {
        running: true
        onTriggered: () => {
            const dt = frameTime;

            // Verlet Integration
            for (const p of path.pathElements.slice(1, root.segmentCount - 2)) {
                const newPos = p.pos.times(2.0).minus(p.prevPos).plus(p.acc.times(dt * dt));
                p.prevPos = p.pos;
                p.pos = newPos;
            }

            // Constraints
            for (let i = 0; i < root.segmentCount - 1; i++) {
                const cur = path.pathElements[i];
                const next = path.pathElements[i + 1];

                for (let j = 0; j < root.constraintRunCount; j++) {
                    const toNext = next.pos.minus(cur.pos);
                    const distToNext = toNext.length();
                    const error = root.segmentLen - distToNext;
                    const pull = toNext.times(1.0 / distToNext).times(error).times(0.1);
                    
                    if (i !== 0) {
                        cur.pos = cur.pos.minus(pull.times(0.5));
                        next.pos = next.pos.plus(pull.times(0.5));
                    } else {
                        next.pos = next.pos.plus(pull);
                    }
                }
            }

            // CORRECTED: Snap start and end to the anchor points at the END of the frame
            path.pathElements[0].pos = root.start;
            path.pathElements[root.segmentCount - 1].pos = root.end;

            path.startX = path.pathElements[0].x;
            path.startY = path.pathElements[0].y;
        }
    }
}
