import { useEffect, useState } from "react";
import { Icon } from "../lib/icons";
import type { IconName } from "../lib/icons";
import {
  AppBar,
  Art,
  Badge,
  Banner,
  Button,
  Card,
  Chip,
  EmptyState,
  Group,
  Mosaic,
  SectionHead,
  SettingRow,
  Toggle,
  useLyra,
} from "../lib/ui";
import { playlists, songs, themeList } from "../lib/data";
import { Wordmark } from "./core";

/* ---------------------------------------------------------- 23 EQUALIZER */

const bands = ["60", "150", "400", "1k", "2.4k", "6k", "12k", "16k"];
const presets: Record<string, number[]> = {
  Flat: [50, 50, 50, 50, 50, 50, 50, 50],
  Classical: [62, 58, 50, 46, 48, 56, 64, 66],
  Rock: [74, 66, 48, 42, 52, 66, 72, 70],
  Pop: [54, 62, 70, 68, 60, 52, 50, 48],
  Jazz: [66, 58, 52, 56, 60, 62, 58, 54],
  Bass: [86, 78, 62, 50, 46, 44, 44, 44],
};

export function EqualizerScreen() {
  const { back, notify } = useLyra();
  const [on, setOn] = useState(true);
  const [preset, setPreset] = useState("Rock");
  const [values, setValues] = useState<number[]>(presets.Rock);
  const [bass, setBass] = useState(42);
  const [virt, setVirt] = useState(26);

  const applyPreset = (p: string) => {
    setPreset(p);
    setValues(presets[p]);
  };

  return (
    <div className="px-5 pb-6">
      <AppBar
        title="Equalizer"
        subtitle="Global playback"
        onBack={back}
        right={<Toggle on={on} onChange={(v) => { setOn(v); notify(v ? "Equalizer on" : "Equalizer off"); }} />}
      />

      <div className="mb-4">
        <Banner icon="info" title="These settings apply to all playback" text="Every song, playlist and queue uses the same audio chain." />
      </div>

      <SectionHead title="Presets" action={preset === "Custom" ? "Custom" : preset} />
      <div className="no-bar -mx-5 mb-5 flex gap-2 overflow-x-auto px-5">
        {Object.keys(presets).map((p) => (
          <Chip key={p} active={preset === p} onClick={() => applyPreset(p)}>
            {p}
          </Chip>
        ))}
        <Chip active={preset === "Custom"} onClick={() => setPreset("Custom")}>
          Custom
        </Chip>
      </div>

      <div
        className="rounded-[var(--r-lg)] border border-[var(--divider)] bg-[var(--surface)] p-4"
        style={{ opacity: on ? 1 : 0.45 }}
      >
        <div className="mb-3 flex justify-between">
          <span className="t-label text-[var(--text-3)]">+12 dB</span>
          <span className="t-label text-[var(--text-3)]">Manual</span>
        </div>
        <div className="flex items-end justify-between gap-1.5">
          {bands.map((b, i) => (
            <div key={b} className="flex flex-1 flex-col items-center gap-2">
              <div className="relative h-[120px] w-full">
                <div className="absolute left-1/2 top-0 h-full w-[3px] -translate-x-1/2 rounded-full bg-[var(--divider-strong)]" />
                <div
                  className="absolute left-1/2 w-[3px] -translate-x-1/2 rounded-full transition-all duration-300"
                  style={{
                    background: "var(--primary)",
                    bottom: `${Math.min(values[i], 50)}%`,
                    height: `${Math.abs(values[i] - 50)}%`,
                  }}
                />
                <div
                  className="absolute left-1/2 h-3.5 w-3.5 -translate-x-1/2 rounded-full border-2 border-[var(--bg)] bg-[var(--text)] shadow transition-all duration-300"
                  style={{ bottom: `calc(${values[i]}% - 7px)` }}
                />
                <input
                  type="range"
                  min={0}
                  max={100}
                  value={values[i]}
                  aria-label={`Band ${b}`}
                  onChange={(e) => {
                    const next = [...values];
                    next[i] = Number(e.target.value);
                    setValues(next);
                    setPreset("Custom");
                  }}
                  className="range range-v absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 cursor-pointer opacity-0"
                />
              </div>
              <span className="t-tech text-[9px] text-[var(--text-3)]">{b}</span>
            </div>
          ))}
        </div>
        <div className="mt-2 flex justify-between">
          <span className="t-label text-[var(--text-3)]">−12 dB</span>
          <button onClick={() => applyPreset("Flat")} className="press t-meta font-bold text-[var(--primary)]">
            Reset
          </button>
        </div>
      </div>

      <div className="mt-4 space-y-3">
        <SliderCard icon="volume" title="Bass boost" value={bass} onChange={setBass} hint="Low frequency emphasis" />
        <SliderCard icon="wave" title="Virtualizer" value={virt} onChange={setVirt} hint="Wider stereo image" />
      </div>
    </div>
  );
}

function SliderCard({
  icon,
  title,
  value,
  onChange,
  hint,
}: {
  icon: IconName;
  title: string;
  value: number;
  onChange: (v: number) => void;
  hint: string;
}) {
  return (
    <Card>
      <div className="flex items-center gap-3">
        <span className="grid h-9 w-9 place-items-center rounded-[11px]" style={{ background: "var(--surface-2)", color: "var(--primary)" }}>
          <Icon name={icon} size={17} />
        </span>
        <div className="min-w-0 flex-1">
          <p className="t-title">{title}</p>
          <p className="t-meta text-[var(--text-3)]">{hint}</p>
        </div>
        <span className="t-tech text-[var(--text-2)]">{value}%</span>
      </div>
      <input
        type="range"
        min={0}
        max={100}
        value={value}
        aria-label={title}
        onChange={(e) => onChange(Number(e.target.value))}
        className="range mt-3 h-4 w-full cursor-pointer"
      />
    </Card>
  );
}

/* ---------------------------------------------------------- 24 AUDIO SETTINGS */

export function AudioScreen() {
  const { back, go, notify } = useLyra();
  const [crossfade, setCrossfade] = useState(true);
  const [speed, setSpeed] = useState("1.0x");
  const [gapless, setGapless] = useState(true);
  const [normalise, setNormalise] = useState(false);

  return (
    <div className="space-y-4 px-5 pb-6">
      <AppBar title="Audio" subtitle="Playback engine" onBack={back} />

      <Card onClick={() => go("equalizer")} className="flex items-center gap-3">
        <span className="grid h-10 w-10 place-items-center rounded-[12px]" style={{ background: "var(--primary-soft)", color: "var(--primary)" }}>
          <Icon name="eq" size={19} />
        </span>
        <span className="min-w-0 flex-1">
          <span className="t-title block">Equalizer</span>
          <span className="t-meta block text-[var(--text-2)]">Rock preset · bass boost 42%</span>
        </span>
        <Icon name="chevronRight" size={16} className="text-[var(--text-3)]" />
      </Card>

      <section>
        <p className="t-label mb-2 px-1 text-[var(--text-3)]">Playback speed</p>
        <div className="grid grid-cols-3 gap-2">
          {["0.5x", "0.75x", "1.0x", "1.25x", "1.5x", "2.0x"].map((s) => (
            <button
              key={s}
              onClick={() => {
                setSpeed(s);
                notify(`Speed ${s}`);
              }}
              className="press t-button h-10 rounded-[var(--r-sm)] border"
              style={{
                borderColor: speed === s ? "transparent" : "var(--divider)",
                background: speed === s ? "var(--primary)" : "var(--surface)",
                color: speed === s ? "var(--on-primary)" : "var(--text-2)",
              }}
            >
              {s}
            </button>
          ))}
        </div>
        <p className="t-meta mt-2 px-1 text-[var(--text-3)]">Pitch is preserved at every speed.</p>
      </section>

      <Group title="Transitions">
        <SettingRow
          icon="wave"
          title="Crossfade"
          value={crossfade ? "On · 6 seconds" : "Off"}
          right={<Toggle on={crossfade} onChange={setCrossfade} />}
        />
        {crossfade && (
          <div className="px-4 pb-4 pt-1">
            <input type="range" min={1} max={12} defaultValue={6} aria-label="Crossfade duration" className="range h-4 w-full cursor-pointer" />
            <div className="mt-1 flex justify-between">
              <span className="t-meta text-[var(--text-3)]">1 s</span>
              <span className="t-meta text-[var(--text-3)]">12 s</span>
            </div>
          </div>
        )}
        <SettingRow icon="note" title="Gapless playback" value="Seamless album transitions" right={<Toggle on={gapless} onChange={setGapless} />} />
        <SettingRow icon="volume" title="Volume normalisation" value="Even loudness across files" right={<Toggle on={normalise} onChange={setNormalise} />} />
      </Group>

      <Group title="Output">
        <SettingRow icon="volume" title="Audio focus" value="Pause on calls and other apps" right={<Toggle on />} />
        <SettingRow icon="bell" title="Resume after interruption" value="Continue where playback stopped" right={<Toggle on />} />
        <SettingRow icon="clock" title="Sleep timer" value="Off" />
      </Group>
    </div>
  );
}

/* ---------------------------------------------------------- 25 SETTINGS */

export function SettingsScreen() {
  const { go, online, setOnline, notify, theme } = useLyra();
  const themeName = themeList.find((t) => t.id === theme)?.label ?? "Lyra Night";

  return (
    <div className="space-y-4 px-5 pb-6">
      <AppBar title="Settings" large />

      <Group title="Playback">
        <SettingRow icon="play" title="Autoplay similar songs" value="Continue with local tracks" right={<Toggle on />} />
        <SettingRow icon="repeat" title="Repeat" value="Repeat all" />
        <SettingRow icon="shuffle" title="Shuffle" value="Off" right={<Toggle on={false} />} />
        <SettingRow icon="wave" title="Crossfade" value="On · 6 s" onClick={() => go("audio")} />
        <SettingRow icon="speed" title="Playback speed" value="1.0x" onClick={() => go("audio")} />
      </Group>

      <Group title="Audio">
        <SettingRow icon="eq" title="Equalizer" value="Rock" onClick={() => go("equalizer")} />
        <SettingRow icon="volume" title="Bass boost" value="42%" onClick={() => go("equalizer")} />
        <SettingRow icon="wave" title="Virtualizer" value="26%" onClick={() => go("equalizer")} />
        <SettingRow icon="sparkle" title="Presets" value="6 built-in profiles" onClick={() => go("equalizer")} />
      </Group>

      <Group title="Library">
        <SettingRow icon="scan" title="Scan for music" value="Last scan 14 min ago · 612 songs" onClick={() => notify("Scanning library…")} />
        <SettingRow icon="folder" title="Folders" value="4 included · 1 excluded" onClick={() => go("folders")} />
        <SettingRow icon="clock" title="Automatic refresh" value="When new files appear" right={<Toggle on />} />
        <SettingRow icon="filter" title="Ignore short clips" value="Under 30 seconds" right={<Toggle on />} />
      </Group>

      <Group title="Appearance">
        <SettingRow icon="moon" title="Theme" value={themeName} onClick={() => go("themes")} />
        <SettingRow icon="sun" title="Follow system theme" value="Switches with your phone" right={<Toggle on />} />
        <SettingRow icon="image" title="Colour from artwork" value="Tint the player with album colours" right={<Toggle on={false} />} />
      </Group>

      <Group title="Data">
        <SettingRow icon="tag" title="Metadata" value="Write tags to files when possible" onClick={() => go("metadata")} />
        <SettingRow icon="lyrics" title="Lyrics" value="Download and store locally" onClick={() => go("lyrics")} />
        <SettingRow icon="image" title="Artwork" value="High confidence only" onClick={() => go("artwork")} />
        <SettingRow icon="trash" title="Local cache" value="86 MB · artwork and lyrics" onClick={() => notify("Cache cleared")} />
      </Group>

      <Group title="System">
        <SettingRow icon="shield" title="Permissions" value="Music access granted" onClick={() => go("permission")} />
        <SettingRow icon="bell" title="Notifications" value="Playback controls on lock screen" right={<Toggle on />} />
        <SettingRow icon="note" title="Background playback" value="Keep playing when app is closed" right={<Toggle on />} />
        <SettingRow
          icon="offline"
          title="Simulate offline mode"
          value={online ? "Currently online" : "Currently offline"}
          right={<Toggle on={!online} onChange={(v) => { setOnline(!v); go(v ? "offline" : "settings"); }} />}
        />
      </Group>

      <Group title="States (prototype)">
        <SettingRow icon="offline" title="Offline experience" onClick={() => go("offline")} />
        <SettingRow icon="note" title="Empty states" onClick={() => go("empty")} />
        <SettingRow icon="alert" title="Error states" onClick={() => go("errors")} />
      </Group>

      <Group title="About">
        <div className="flex items-center gap-3 p-4">
          <Wordmark size={34} />
        </div>
        <SettingRow icon="info" title="Version" value="1.0.0 (build 118) · local player" right={<span />} />
        <SettingRow icon="shield" title="Privacy" value="No account, no tracking, no cloud" right={<span />} />
        <SettingRow icon="sparkle" title="Open source licences" />
      </Group>

      <p className="t-meta pt-1 text-center text-[var(--text-3)]">
        Internet enriches LyraMusic — it is never required to play your music.
      </p>
    </div>
  );
}

/* ---------------------------------------------------------- 26 THEMES */

export function ThemesScreen() {
  const { back, theme, setTheme, notify } = useLyra();

  const swatches: Record<string, string[]> = {
    system: ["#0b0b11", "#14141d", "#7b6cff", "#f4f3f8"],
    dark: ["#0b0b11", "#14141d", "#7b6cff", "#f4f3f8"],
    light: ["#faf8f5", "#ffffff", "#5b4ae0", "#16151c"],
    graphite: ["#0e0f11", "#17181b", "#9aa4b8", "#f0f1f3"],
    amber: ["#100c08", "#1a1410", "#e2974a", "#f7f1e8"],
    bloom: ["#110a10", "#1b1019", "#e8719c", "#fbf0f6"],
  };

  return (
    <div className="px-5 pb-6">
      <AppBar title="Themes" subtitle="Appearance" onBack={back} />

      <div className="mb-4">
        <Banner icon="info" title="Same app, different mood" text="Every theme keeps the identical layout, spacing and interactions." />
      </div>

      <div className="grid grid-cols-2 gap-3">
        {themeList.map((t) => {
          const s = swatches[t.id] ?? swatches.dark;
          const active = theme === t.id;
          return (
            <button
              key={t.id}
              onClick={() => {
                setTheme(t.id);
                notify(`${t.label} theme applied`);
              }}
              className="press rounded-[var(--r-lg)] border p-2 text-left transition-all"
              style={{
                borderColor: active ? "var(--primary)" : "var(--divider)",
                background: active ? "var(--primary-soft)" : "transparent",
              }}
            >
              <div className="overflow-hidden rounded-[14px]" style={{ background: s[0] }}>
                <div className="p-2.5">
                  <div className="flex items-center gap-1.5">
                    <span className="h-5 w-5 rounded-[6px]" style={{ background: s[2] }} />
                    <span className="h-1.5 w-10 rounded-full" style={{ background: s[3], opacity: 0.8 }} />
                  </div>
                  <div className="mt-2.5 rounded-[9px] p-2" style={{ background: s[1] }}>
                    <div className="flex items-center gap-1.5">
                      <span className="h-6 w-6 rounded-[5px]" style={{ background: s[2], opacity: 0.85 }} />
                      <span className="flex-1 space-y-1">
                        <span className="block h-1.5 w-full rounded-full" style={{ background: s[3], opacity: 0.55 }} />
                        <span className="block h-1.5 w-2/3 rounded-full" style={{ background: s[3], opacity: 0.25 }} />
                      </span>
                    </div>
                  </div>
                  <div className="mt-2 flex items-center gap-1">
                    <span className="h-1 flex-1 rounded-full" style={{ background: s[2] }} />
                    <span className="h-1 w-5 rounded-full" style={{ background: s[3], opacity: 0.25 }} />
                  </div>
                </div>
              </div>
              <div className="mt-2 flex items-center justify-between px-0.5">
                <div>
                  <p className="t-title">{t.label}</p>
                  <p className="t-meta text-[var(--text-3)]">{t.sub}</p>
                </div>
                {active && (
                  <span className="grid h-5 w-5 place-items-center rounded-full text-[var(--on-primary)]" style={{ background: "var(--primary)" }}>
                    <Icon name="check" size={11} />
                  </span>
                )}
              </div>
            </button>
          );
        })}
      </div>

      <p className="t-meta mt-5 text-center text-[var(--text-3)]">
        Custom and imported themes are not part of version 1.
      </p>
    </div>
  );
}

/* ---------------------------------------------------------- 27 OFFLINE */

export function OfflineScreen() {
  const { back, go, setOnline, notify } = useLyra();
  return (
    <div className="px-5 pb-6">
      <AppBar title="Offline" subtitle="Connection status" onBack={back} />

      <div className="flex items-center gap-3 rounded-[var(--r-lg)] border border-[var(--divider)] bg-[var(--surface)] p-4">
        <span className="grid h-11 w-11 shrink-0 place-items-center rounded-full" style={{ background: "color-mix(in srgb,var(--warning) 14%,transparent)", color: "var(--warning)" }}>
          <Icon name="offline" size={20} />
        </span>
        <div className="min-w-0 flex-1">
          <p className="t-h3">You are offline</p>
          <p className="t-meta text-[var(--text-2)]">Your music keeps playing. Only online extras are paused.</p>
        </div>
      </div>

      <div className="mt-5">
        <SectionHead title="Still fully available" />
        <Group>
          {[
            ["note", "Local library", "612 songs ready to play"],
            ["play", "Playback & queue", "No connection needed"],
            ["playlist", "Playlists", "Stored on device"],
            ["heart", "Favorites", "Stored on device"],
            ["clock", "History", "Stored on device"],
            ["image", "Saved artwork & lyrics", "Downloaded earlier"],
          ].map(([i, t, v]) => (
            <SettingRow
              key={t}
              icon={i as IconName}
              title={t}
              value={v}
              tone="var(--success)"
              right={
                <span className="text-[var(--success)]">
                  <Icon name="check" size={16} />
                </span>
              }
            />
          ))}
        </Group>
      </div>

      <div className="mt-4">
        <SectionHead title="Paused until you reconnect" />
        <Group>
          {[
            ["cloudDown", "Metadata lookup", "Will resume automatically"],
            ["image", "Artwork download", "Will resume automatically"],
            ["lyrics", "Lyrics search", "Saved lyrics still work"],
          ].map(([i, t, v]) => (
            <SettingRow key={t} icon={i as IconName} title={t} value={v} right={<Badge>Paused</Badge>} />
          ))}
        </Group>
      </div>

      <div className="mt-5 flex gap-2">
        <Button
          full
          onClick={() => {
            setOnline(true);
            notify("Back online");
            go("home");
          }}
        >
          Reconnect
        </Button>
        <Button variant="secondary" full onClick={() => go("songs")}>
          Keep browsing
        </Button>
      </div>
      <p className="t-meta mt-3 text-center text-[var(--text-3)]">
        LyraMusic never blocks the app when the connection drops.
      </p>
    </div>
  );
}

/* ---------------------------------------------------------- 28 EMPTY STATES */

export function EmptyStatesScreen() {
  const { back, go } = useLyra();
  const items: [IconName, string, string, string][] = [
    ["note", "No music found", "We could not find audio files on this device. Add music or choose another folder.", "Choose folders"],
    ["playlist", "No playlists yet", "Group songs by mood, place or moment. Everything stays on your phone.", "Create playlist"],
    ["heart", "No favorites yet", "Tap the heart on a song to find it instantly here.", "Browse library"],
    ["clock", "No playback history", "Songs you listen to will appear here, grouped by day.", "Play something"],
    ["search", "No results", "Nothing matches that search in your local library.", "Clear search"],
    ["lyrics", "Lyrics unavailable", "No .LRC file found locally and nothing downloaded yet.", "Search for lyrics"],
    ["alert", "No compatible files", "This folder contains files LyraMusic cannot play.", "Pick another folder"],
  ];
  return (
    <div className="px-5 pb-6">
      <AppBar title="Empty states" subtitle="Prototype reference" onBack={back} />
      <div className="space-y-3 pt-1">
        {items.map(([icon, title, text, action]) => (
          <EmptyState key={title} compact icon={icon} title={title} text={text} action={action} onAction={() => go("home")} />
        ))}
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 29 ERROR STATES */

export function ErrorStatesScreen() {
  const { back, notify } = useLyra();
  const items: [IconName, string, string, string, "warn" | "err"][] = [
    ["alert", "This file cannot be played", "Cassette Loop 04.amr seems damaged or uses an unsupported codec.", "Skip to next song", "err"],
    ["tag", "Tags could not be written", "This file is read-only. LyraMusic saved your changes in the app instead.", "Keep local copy", "warn"],
    ["offline", "No connection", "Online enrichment is paused. Local playback is unaffected.", "Continue offline", "warn"],
    ["sparkle", "Nothing reliable found", "No confident match for this song. Existing information was left untouched.", "Edit manually", "warn"],
    ["lyrics", "Lyrics not found", "We looked in three sources and found no synced lyrics for this track.", "Try again", "warn"],
    ["shield", "Access to this folder was refused", "Grant music access to include these songs in your library.", "Review permission", "err"],
  ];
  return (
    <div className="px-5 pb-6">
      <AppBar title="Error states" subtitle="Calm and recoverable" onBack={back} />
      <div className="mb-3">
        <Banner icon="info" title="Never alarming" text="Errors explain what happened in plain words and always offer a way forward." />
      </div>
      <div className="space-y-2.5">
        {items.map(([icon, title, text, action, tone]) => (
          <Banner key={title} icon={icon} tone={tone} title={title} text={text} action={action} onAction={() => notify("Recovery action")} />
        ))}
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 30 SONG CONTEXT MENU */

export function SongMenuContent({ onClose }: { onClose: () => void }) {
  const { go, current, favs, toggleFav, notify } = useLyra();
  const fav = favs.includes(current.id);
  const items: [IconName, string, () => void][] = [
    ["play", "Play now", () => go("player")],
    ["queue", "Play next", () => notify("Playing next")],
    ["queue", "Add to queue", () => notify("Added to queue")],
    ["playlist", "Add to playlist", () => go("playlists")],
    [
      "heart",
      fav ? "Remove from favorites" : "Add to favorites",
      () => {
        toggleFav(current.id);
        notify(fav ? "Removed from Favorites" : "Added to Favorites");
      },
    ],
    ["edit", "Edit information", () => go("metadata")],
    ["sparkle", "Find info online", () => go("enrichment")],
    ["image", "Change artwork", () => go("artwork")],
    ["info", "Song details", () => go("songDetails")],
    ["share", "Share file", () => notify("Share sheet opened")],
  ];

  return (
    <div>
      <div className="flex items-center gap-3 px-5 pb-3">
        <Art src={current.art} size={50} radius={12} />
        <div className="min-w-0 flex-1">
          <p className="t-title clamp-1">{current.title}</p>
          <p className="t-meta clamp-1 text-[var(--text-2)]">
            {current.artist} · {current.format} · {current.duration}
          </p>
        </div>
      </div>
      <div className="px-2">
        {items.map(([icon, label, fn], i) => (
          <button
            key={label + i}
            onClick={() => {
              fn();
              onClose();
            }}
            className="press flex w-full items-center gap-3.5 rounded-[var(--r-md)] px-3 py-2.5 text-left"
          >
            <span style={{ color: label.includes("favorites") && fav ? "var(--primary)" : "var(--text-2)" }}>
              <Icon name={icon} size={18} filled={icon === "heart" && fav} />
            </span>
            <span className="t-title flex-1">{label}</span>
          </button>
        ))}
      </div>
      <div className="px-5 pt-2">
        <Button variant="secondary" full onClick={onClose}>
          Close
        </Button>
      </div>
    </div>
  );
}

/* Standalone screen version (#30) showing the menu over the library */

export function SongMenuScreen() {
  const { openSheet, sheet, go } = useLyra();
  useEffect(() => {
    const id = window.setTimeout(() => openSheet("menu"), 260);
    return () => window.clearTimeout(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
  return (
    <div className="relative h-full">
      <div className="px-5 pb-4 opacity-60">
        <AppBar title="Library" subtitle="Song actions" large />
        <div className="space-y-0.5 pt-2">
          {songs.slice(0, 6).map((s, i) => (
            <div key={s.id} className="flex items-center gap-3 py-1.5">
              <Art src={s.art} size={44} radius={12} seed={i} />
              <div className="min-w-0 flex-1">
                <p className="t-title clamp-1">{s.title}</p>
                <p className="t-meta clamp-1 text-[var(--text-2)]">{s.artist}</p>
              </div>
              <Icon name="more" size={17} className="text-[var(--text-3)]" />
            </div>
          ))}
        </div>
      </div>
      {sheet !== "menu" && (
        <div className="absolute inset-x-5 bottom-6">
          <Button full onClick={() => openSheet("menu")}>
            Open song menu
          </Button>
        </div>
      )}
      {sheet !== "menu" && (
        <button onClick={() => go("songs")} className="press t-meta absolute inset-x-0 bottom-1 text-center text-[var(--text-3)]">
          Back to library
        </button>
      )}
    </div>
  );
}

/* Extra: playlist picker sheet */

export function AddToPlaylistContent({ onClose }: { onClose: () => void }) {
  const { notify } = useLyra();
  return (
    <div>
      <div className="px-2">
        <button
          onClick={() => {
            notify("New playlist created");
            onClose();
          }}
          className="press flex w-full items-center gap-3 rounded-[var(--r-md)] px-3 py-3 text-left"
        >
          <span className="grid h-11 w-11 place-items-center rounded-[12px]" style={{ background: "var(--primary-soft)", color: "var(--primary)" }}>
            <Icon name="plus" size={18} />
          </span>
          <span className="t-title">New playlist</span>
        </button>
        {playlists.map((p) => (
          <button
            key={p.id}
            onClick={() => {
              notify(`Added to ${p.name}`);
              onClose();
            }}
            className="press flex w-full items-center gap-3 rounded-[var(--r-md)] px-3 py-2 text-left"
          >
            <Mosaic art={p.art} size={44} radius={11} />
            <span className="min-w-0 flex-1">
              <span className="t-title clamp-1 block">{p.name}</span>
              <span className="t-meta block text-[var(--text-2)]">{p.count} songs</span>
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}
