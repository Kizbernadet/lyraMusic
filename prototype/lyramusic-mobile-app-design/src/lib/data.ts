export type Song = {
  id: string;
  title: string;
  artist: string;
  album: string;
  art: string | null;
  duration: string;
  seconds: number;
  year?: string;
  genre?: string;
  composer?: string;
  track?: string;
  folder: string;
  format: string;
  bitrate: string;
  incomplete?: boolean;
  broken?: boolean;
};

const A = (f: string) => `art/${f}.jpg`;

export const ART = {
  nightOrchard: A("night-orchard"),
  glassHarbor: A("glass-harbor"),
  privateMasters: A("private-masters"),
  rooms: A("rooms-without-walls"),
  softMachines: A("soft-machines"),
  ember: A("ember-static"),
  paper: A("paper-lanterns"),
  sodium: A("sodium-lights"),
};

export const songs: Song[] = [
  {
    id: "s1",
    title: "Velvet Satellites",
    artist: "Mira Vale",
    album: "Night Orchard",
    art: ART.nightOrchard,
    duration: "4:18",
    seconds: 258,
    year: "2024",
    genre: "Dream Pop",
    composer: "M. Vale",
    track: "3",
    folder: "/Music/Mira Vale/Night Orchard",
    format: "FLAC",
    bitrate: "1 002 kbps · 44.1 kHz",
  },
  {
    id: "s2",
    title: "Low Tide Signals",
    artist: "The Northern Arc",
    album: "Glass Harbor",
    art: ART.glassHarbor,
    duration: "3:42",
    seconds: 222,
    year: "2022",
    genre: "Alternative",
    composer: "J. Hald",
    track: "1",
    folder: "/Music/The Northern Arc",
    format: "MP3",
    bitrate: "320 kbps · 44.1 kHz",
  },
  {
    id: "s3",
    title: "Amber Room (Unfinished Working Mix For The Winter Sessions)",
    artist: "Solenne",
    album: "Private Masters",
    art: ART.privateMasters,
    duration: "5:06",
    seconds: 306,
    year: "2019",
    genre: "Indie",
    composer: "Solenne",
    track: "7",
    folder: "/Downloads/Audio",
    format: "M4A",
    bitrate: "256 kbps · 48 kHz",
  },
  {
    id: "s4",
    title: "Unknown Track",
    artist: "Unknown Artist",
    album: "Unknown Album",
    art: null,
    duration: "2:57",
    seconds: 177,
    folder: "/Downloads/Audio",
    format: "MP3",
    bitrate: "192 kbps · 44.1 kHz",
    incomplete: true,
  },
  {
    id: "s5",
    title: "Afterimage Piano",
    artist: "Elian Rowe",
    album: "Rooms Without Walls",
    art: ART.rooms,
    duration: "3:31",
    seconds: 211,
    year: "2021",
    genre: "Modern Classical",
    composer: "E. Rowe",
    track: "2",
    folder: "/Music/Elian Rowe",
    format: "FLAC",
    bitrate: "988 kbps · 44.1 kHz",
  },
  {
    id: "s6",
    title: "Circuit Bloom",
    artist: "Maiko Line",
    album: "Soft Machines",
    art: ART.softMachines,
    duration: "4:44",
    seconds: 284,
    year: "2023",
    genre: "Electronic",
    composer: "M. Line",
    track: "5",
    folder: "/Music/Maiko Line",
    format: "OPUS",
    bitrate: "160 kbps · 48 kHz",
  },
  {
    id: "s7",
    title: "Ember Static",
    artist: "Hale & Orren",
    album: "Ember Static",
    art: ART.ember,
    duration: "3:08",
    seconds: 188,
    year: "2020",
    genre: "Ambient",
    composer: "T. Hale",
    track: "4",
    folder: "/Music/Compilations",
    format: "MP3",
    bitrate: "320 kbps · 44.1 kHz",
  },
  {
    id: "s8",
    title: "Paper Lanterns",
    artist: "Juno Marsh",
    album: "Paper Lanterns",
    art: ART.paper,
    duration: "2:49",
    seconds: 169,
    year: "2018",
    genre: "Folk",
    composer: "J. Marsh",
    track: "1",
    folder: "/Recordings",
    format: "WAV",
    bitrate: "1 411 kbps · 44.1 kHz",
  },
  {
    id: "s9",
    title: "Sodium Lights",
    artist: "The Northern Arc",
    album: "Sodium Lights",
    art: ART.sodium,
    duration: "5:21",
    seconds: 321,
    year: "2025",
    genre: "Alternative",
    composer: "J. Hald",
    track: "6",
    folder: "/Music/The Northern Arc",
    format: "FLAC",
    bitrate: "1 108 kbps · 48 kHz",
  },
  {
    id: "s10",
    title: "Cassette Loop 04",
    artist: "Unknown Artist",
    album: "Unknown Album",
    art: null,
    duration: "1:52",
    seconds: 112,
    folder: "/Recordings",
    format: "AMR",
    bitrate: "12 kbps · 8 kHz",
    incomplete: true,
    broken: true,
  },
];

export const byId = (id: string) => songs.find((s) => s.id === id) ?? songs[0];

export type Album = {
  id: string;
  title: string;
  artist: string;
  art: string | null;
  year: string;
  count: number;
};

export const albums: Album[] = [
  { id: "a1", title: "Night Orchard", artist: "Mira Vale", art: ART.nightOrchard, year: "2024", count: 11 },
  { id: "a2", title: "Glass Harbor", artist: "The Northern Arc", art: ART.glassHarbor, year: "2022", count: 9 },
  { id: "a3", title: "Soft Machines", artist: "Maiko Line", art: ART.softMachines, year: "2023", count: 12 },
  { id: "a4", title: "Rooms Without Walls", artist: "Elian Rowe", art: ART.rooms, year: "2021", count: 8 },
  { id: "a5", title: "Private Masters", artist: "Solenne", art: ART.privateMasters, year: "2019", count: 14 },
  { id: "a6", title: "Unknown Album", artist: "Unknown Artist", art: null, year: "—", count: 3 },
];

export const artists = [
  { name: "The Northern Arc", albums: 3, tracks: 28, art: ART.glassHarbor },
  { name: "Mira Vale", albums: 2, tracks: 19, art: ART.nightOrchard },
  { name: "Maiko Line", albums: 2, tracks: 21, art: ART.softMachines },
  { name: "Elian Rowe", albums: 1, tracks: 8, art: ART.rooms },
  { name: "Juno Marsh", albums: 1, tracks: 10, art: ART.paper },
  { name: "Solenne", albums: 1, tracks: 14, art: ART.privateMasters },
  { name: "Unknown Artist", albums: 0, tracks: 3, art: null },
];

export const genres = [
  { name: "Dream Pop", tracks: 42, art: ART.nightOrchard },
  { name: "Alternative", tracks: 76, art: ART.sodium },
  { name: "Electronic", tracks: 58, art: ART.softMachines },
  { name: "Modern Classical", tracks: 24, art: ART.rooms },
  { name: "Folk", tracks: 31, art: ART.paper },
  { name: "Ambient", tracks: 19, art: ART.ember },
];

export const folders = [
  { path: "Music", sub: "Internal storage · 7 subfolders", count: 612, pinned: true },
  { path: "Downloads/Audio", sub: "Internal storage", count: 48 },
  { path: "Recordings", sub: "Internal storage", count: 23 },
  { path: "Imported/Archive", sub: "SD card", count: 184 },
  { path: "Podcasts", sub: "Excluded from library", count: 0, excluded: true },
];

export type Playlist = {
  id: string;
  name: string;
  count: number;
  art: string[];
  updated: string;
};

export const playlists: Playlist[] = [
  { id: "p1", name: "Late Night Focus", count: 24, updated: "Edited 2 days ago", art: [ART.nightOrchard, ART.rooms, ART.ember, ART.softMachines] },
  { id: "p2", name: "Road Home", count: 41, updated: "Edited last week", art: [ART.sodium, ART.glassHarbor, ART.paper, ART.privateMasters] },
  { id: "p3", name: "Piano & Rain", count: 12, updated: "Edited in March", art: [ART.rooms, ART.paper, ART.nightOrchard, ART.ember] },
  { id: "p4", name: "Tape Finds", count: 7, updated: "Edited in March", art: [ART.privateMasters, ART.ember, ART.softMachines, ART.sodium] },
];

export const lyrics = [
  { t: "00:42", line: "The harbour lights are folding in" },
  { t: "00:49", line: "Every window keeps the rain" },
  { t: "00:56", line: "I hear you humming through the static" },
  { t: "01:03", line: "Velvet satellites again" },
  { t: "01:11", line: "And the room begins to sway" },
  { t: "01:19", line: "I keep the chorus in my pocket" },
  { t: "01:27", line: "For the long walk home tonight" },
  { t: "01:35", line: "Every streetlight turns to silver" },
  { t: "01:43", line: "Every silence turns to light" },
];

export type ScreenId =
  | "splash"
  | "permission"
  | "home"
  | "songs"
  | "albums"
  | "artists"
  | "genres"
  | "folders"
  | "search"
  | "results"
  | "player"
  | "queue"
  | "playlists"
  | "createPlaylist"
  | "playlistDetail"
  | "favorites"
  | "history"
  | "songDetails"
  | "metadata"
  | "enrichment"
  | "artwork"
  | "lyrics"
  | "equalizer"
  | "audio"
  | "settings"
  | "themes"
  | "offline"
  | "empty"
  | "errors"
  | "menu";

export const screenIndex: { id: ScreenId; n: string; label: string; group: string }[] = [
  { id: "splash", n: "01", label: "Splash", group: "Onboarding" },
  { id: "permission", n: "02", label: "Music Permission", group: "Onboarding" },
  { id: "home", n: "03", label: "Home", group: "Core" },
  { id: "songs", n: "04", label: "Library · Songs", group: "Core" },
  { id: "albums", n: "05", label: "Library · Albums", group: "Core" },
  { id: "artists", n: "06", label: "Library · Artists", group: "Core" },
  { id: "genres", n: "07", label: "Library · Genres", group: "Core" },
  { id: "folders", n: "08", label: "Library · Folders", group: "Core" },
  { id: "search", n: "09", label: "Search", group: "Core" },
  { id: "results", n: "10", label: "Search Results", group: "Core" },
  { id: "player", n: "11", label: "Full Player", group: "Playback" },
  { id: "queue", n: "12", label: "Queue", group: "Playback" },
  { id: "lyrics", n: "22", label: "Lyrics", group: "Playback" },
  { id: "playlists", n: "13", label: "Playlists", group: "Collections" },
  { id: "createPlaylist", n: "14", label: "Create Playlist", group: "Collections" },
  { id: "playlistDetail", n: "15", label: "Playlist Detail", group: "Collections" },
  { id: "favorites", n: "16", label: "Favorites", group: "Collections" },
  { id: "history", n: "17", label: "Playback History", group: "Collections" },
  { id: "songDetails", n: "18", label: "Song Details", group: "Metadata" },
  { id: "metadata", n: "19", label: "Metadata Editor", group: "Metadata" },
  { id: "enrichment", n: "20", label: "Enrichment", group: "Metadata" },
  { id: "artwork", n: "21", label: "Artwork Selection", group: "Metadata" },
  { id: "equalizer", n: "23", label: "Equalizer", group: "Audio" },
  { id: "audio", n: "24", label: "Audio Settings", group: "Audio" },
  { id: "settings", n: "25", label: "Settings", group: "System" },
  { id: "themes", n: "26", label: "Themes", group: "System" },
  { id: "offline", n: "27", label: "Offline State", group: "States" },
  { id: "empty", n: "28", label: "Empty States", group: "States" },
  { id: "errors", n: "29", label: "Error States", group: "States" },
  { id: "menu", n: "30", label: "Song Context Menu", group: "States" },
];

export const themeList = [
  { id: "system", label: "Automatic", sub: "Follows system", theme: "dark" },
  { id: "light", label: "Daylight", sub: "Light theme", theme: "light" },
  { id: "dark", label: "Lyra Night", sub: "Default dark", theme: "dark" },
  { id: "graphite", label: "Graphite", sub: "Neutral dark", theme: "graphite" },
  { id: "amber", label: "Amber Room", sub: "Warm dark", theme: "amber" },
  { id: "bloom", label: "Bloom", sub: "Rose dark", theme: "bloom" },
];
