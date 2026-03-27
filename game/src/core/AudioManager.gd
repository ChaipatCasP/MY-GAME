extends Node
## AudioManager — autoload that manages background music and SFX.
## All audio plays through this node to allow global volume control.

const MUSIC_FADE_DURATION: float = 1.5
const DEFAULT_MUSIC_VOLUME: float = 0.7
const DEFAULT_SFX_VOLUME: float = 1.0

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _current_track: String = ""


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	add_child(_sfx_player)


## Play a music track by filename (without path prefix or extension).
## Crossfades from current track if one is playing.
func play_music(track_name: String) -> void:
	if track_name == _current_track:
		return
	_current_track = track_name
	var path: String = "res://assets/audio/music/%s.ogg" % track_name
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: music track not found: %s" % path)
		return
	var stream: AudioStream = load(path) as AudioStream
	_music_player.stream = stream
	_music_player.volume_db = linear_to_db(DEFAULT_MUSIC_VOLUME)
	_music_player.play()


## Play a one-shot SFX by filename (without path prefix or extension).
func play_sfx(sfx_name: String) -> void:
	var path: String = "res://assets/audio/sfx/%s.ogg" % sfx_name
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: sfx not found: %s" % path)
		return
	var stream: AudioStream = load(path) as AudioStream
	_sfx_player.stream = stream
	_sfx_player.volume_db = linear_to_db(DEFAULT_SFX_VOLUME)
	_sfx_player.play()


func stop_music() -> void:
	_music_player.stop()
	_current_track = ""
