import bb.cascades 1.4
import bb.multimedia 1.4
import bb.data 1.0

GroupDataModel {
    id: eqModel
    grouping: ItemGrouping.None
    sortedAscending: true
    sortingKeys: ["eid"]
    
    function init() 
    {
        eqModel.clear();
        eqModel.insert({"eid": EqualizerPreset.Off, "title": "Off"})
        eqModel.insert({"eid": EqualizerPreset.Airplane, "title": "Airplane"})
        eqModel.insert({"eid": EqualizerPreset.BassBoost, "title": "Bass Boost"})
        eqModel.insert({"eid": EqualizerPreset.TrebleBoost, "title": "Treble Boost"})
        eqModel.insert({"eid": EqualizerPreset.VoiceBoost, "title": "Voice Boost"})
        eqModel.insert({"eid": EqualizerPreset.BassLower, "title": "Bass Lower"})
        eqModel.insert({"eid": EqualizerPreset.TrebleLower, "title": "Treble Lower"})
        eqModel.insert({"eid": EqualizerPreset.VoiceLower, "title": "Voice Lower"})
        eqModel.insert({"eid": EqualizerPreset.Acoustic, "title": "Acoustic"})
        eqModel.insert({"eid": EqualizerPreset.Dance, "title": "Dance"})
        eqModel.insert({"eid": EqualizerPreset.Electronic, "title": "Electronic"})
        eqModel.insert({"eid": EqualizerPreset.HipHop, "title": "Hip Hop"})
        eqModel.insert({"eid": EqualizerPreset.Jazz, "title": "Jazz"})
        eqModel.insert({"eid": EqualizerPreset.Lounge, "title": "Lounge"})
        eqModel.insert({"eid": EqualizerPreset.Piano, "title": "Piano"})
        eqModel.insert({"eid": EqualizerPreset.RhythmAndBlues, "title": "Rhythm and Blues"})
        eqModel.insert({"eid": EqualizerPreset.Rock, "title": "Rock"})
        eqModel.insert({"eid": EqualizerPreset.SpokenWord, "title": "Spoken Word"})
    }
}