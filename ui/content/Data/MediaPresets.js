.pragma library

function defaultPresets() {
    return [
        { name: "Flat", bass: 0, mid: 0, treble: 0, deletable: false },
        { name: "Bass Boost", bass: 6, mid: 1, treble: 0, deletable: false },
        { name: "Treble Boost", bass: 0, mid: 1, treble: 6, deletable: false },
        { name: "Rock", bass: 5, mid: -1, treble: 4, deletable: false },
        { name: "Pop", bass: 2, mid: 3, treble: 4, deletable: false },
        { name: "Jazz", bass: 3, mid: 2, treble: 5, deletable: false },
        { name: "Classical", bass: 1, mid: 2, treble: 6, deletable: false },
        { name: "Vocal", bass: -1, mid: 6, treble: 2, deletable: false },
        { name: "Electronic", bass: 6, mid: 0, treble: 5, deletable: false },
        { name: "Hip Hop", bass: 7, mid: 1, treble: 2, deletable: false },
        { name: "Dance", bass: 5, mid: 2, treble: 5, deletable: false },
        { name: "R&B", bass: 5, mid: 3, treble: 1, deletable: false },
        { name: "Podcast", bass: -3, mid: 6, treble: 1, deletable: false },
        { name: "Movie", bass: 6, mid: 2, treble: 4, deletable: false },
        { name: "Live", bass: 3, mid: 4, treble: 5, deletable: false },
        { name: "Acoustic", bass: 2, mid: 4, treble: 3, deletable: false },
        { name: "Loudness", bass: 7, mid: -2, treble: 7, deletable: false }
    ]
}