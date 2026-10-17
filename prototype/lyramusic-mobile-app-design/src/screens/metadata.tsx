import { useState } from "react";
import { Icon } from "../lib/icons";
import {
  AppBar,
  Art,
  Badge,
  Banner,
  Button,
  Card,
  Divider,
  Group,
  Progress,
  SectionHead,
  SettingRow,
  useLyra,
} from "../lib/ui";
import { ART, songs } from "../lib/data";

const broken = songs[3];

/* ---------------------------------------------------------- 18 SONG DETAILS */

export function SongDetailsScreen() {
  const { back, go, play, notify, favs, toggleFav } = useLyra();
  const s = broken;
  const fav = favs.includes(s.id);

  return (
    <div className="px-5 pb-4">
      <AppBar
        title="Song details"
        onBack={back}
        right={
          <button aria-label="Edit information" onClick={() => go("metadata")} className="press grid h-9 w-9 place-items-center rounded-full text-[var(--text-2)]">
            <Icon name="edit" size={18} />
          </button>
        }
      />

      <div className="flex flex-col items-center pt-2 text-center">
        <div className="relative">
          <Art src={s.art} size={150} radius={22} />
          <span className="absolute -bottom-2 left-1/2 -translate-x-1/2">
            <Badge tone="warn">Incomplete</Badge>
          </span>
        </div>
        <h1 className="t-h1 mt-5">{s.title}</h1>
        <p className="t-body text-[var(--text-2)]">{s.artist}</p>
        <p className="t-meta text-[var(--text-3)]">{s.album}</p>

        <div className="mt-4 flex w-full gap-2">
          <Button
            full
            icon="play"
            onClick={() => {
              play(s);
              go("player");
            }}
          >
            Play anyway
          </Button>
          <Button
            variant="secondary"
            onClick={() => {
              toggleFav(s.id);
              notify(fav ? "Removed from Favorites" : "Added to Favorites");
            }}
          >
            <Icon name="heart" size={16} filled={fav} />
          </Button>
          <Button variant="secondary" onClick={() => notify("Added to queue")}>
            <Icon name="queue" size={16} />
          </Button>
        </div>
      </div>

      <div className="mt-6 space-y-3">
        <Banner
          icon="alert"
          tone="warn"
          title="Some information is missing"
          text="LyraMusic never invents tags. The file plays normally — you can complete it manually or let LyraMusic look online."
          action="Edit information"
          onAction={() => go("metadata")}
        />

        <Group title="Tags">
          <SettingRow title="Title" value="Unknown Track" right={<Badge tone="warn">Missing</Badge>} />
          <SettingRow title="Artist" value="Unknown Artist" right={<Badge tone="warn">Missing</Badge>} />
          <SettingRow title="Album" value="Unknown Album" right={<Badge tone="warn">Missing</Badge>} />
          <SettingRow title="Genre" value="—" right={<Badge tone="warn">Missing</Badge>} />
          <SettingRow title="Year" value="—" right={<Badge tone="warn">Missing</Badge>} />
          <SettingRow title="Track number" value="—" right={<Badge tone="warn">Missing</Badge>} />
          <SettingRow title="Composer" value="—" right={<Badge tone="warn">Missing</Badge>} />
        </Group>

        <Group title="File">
          <SettingRow icon="folder" title="Location" value={s.folder} right={<span />} />
          <SettingRow icon="wave" title="Format" value={`${s.format} · ${s.bitrate}`} right={<span />} />
          <SettingRow icon="clock" title="Duration" value={s.duration} right={<span />} />
          <SettingRow icon="info" title="File size" value="4.1 MB · added 12 Mar" right={<span />} />
        </Group>

        <div className="flex gap-2">
          <Button variant="secondary" size="sm" full icon="sparkle" onClick={() => go("enrichment")}>
            Find info online
          </Button>
          <Button variant="secondary" size="sm" full icon="image" onClick={() => go("artwork")}>
            Choose artwork
          </Button>
        </div>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 19 METADATA EDITOR */

function Field({
  label,
  value,
  onChange,
  placeholder,
  hint,
  half = false,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  hint?: string;
  half?: boolean;
}) {
  return (
    <label className={`block ${half ? "" : "col-span-2"}`}>
      <span className="t-label block text-[var(--text-3)]">{label}</span>
      <input
        value={value}
        placeholder={placeholder}
        onChange={(e) => onChange(e.target.value)}
        className="t-title mt-1.5 h-11 w-full rounded-[var(--r-sm)] border border-[var(--divider)] bg-[var(--surface)] px-3 text-[var(--text)] outline-none transition-colors placeholder:text-[var(--text-3)] focus:border-[var(--primary)]"
      />
      {hint && <span className="t-meta mt-1 block text-[var(--text-3)]">{hint}</span>}
    </label>
  );
}

export function MetadataScreen() {
  const { back, go, notify } = useLyra();
  const [f, setF] = useState({
    title: "Unknown Track",
    artist: "Unknown Artist",
    album: "Unknown Album",
    genre: "",
    track: "",
    year: "",
    composer: "",
  });
  const set = (k: keyof typeof f) => (v: string) => setF({ ...f, [k]: v });
  const [saved, setSaved] = useState(false);

  return (
    <div className="flex h-full flex-col">
      <div className="px-5">
        <AppBar
          title="Edit information"
          subtitle={broken.format + " file"}
          onBack={back}
          right={
            <Button
              size="sm"
              onClick={() => {
                setSaved(true);
                notify("Tags written to file");
              }}
            >
              Save
            </Button>
          }
        />
      </div>

      <div className="no-bar flex-1 overflow-y-auto px-5 pb-6">
        <button onClick={() => go("artwork")} className="press flex w-full items-center gap-3.5 rounded-[var(--r-lg)] border border-[var(--divider)] bg-[var(--surface)] p-3 text-left">
          <Art src={null} size={64} radius={14} />
          <span className="min-w-0 flex-1">
            <span className="t-title block">Artwork</span>
            <span className="t-meta block text-[var(--text-2)]">No artwork embedded in this file</span>
          </span>
          <span className="t-meta font-bold text-[var(--primary)]">Change</span>
        </button>

        <div className="mt-4 grid grid-cols-2 gap-3">
          <Field label="Title" value={f.title} onChange={set("title")} placeholder="Song title" />
          <Field label="Artist" value={f.artist} onChange={set("artist")} placeholder="Artist" />
          <Field label="Album" value={f.album} onChange={set("album")} placeholder="Album" />
          <Field half label="Genre" value={f.genre} onChange={set("genre")} placeholder="—" />
          <Field half label="Track no." value={f.track} onChange={set("track")} placeholder="—" />
          <Field half label="Year" value={f.year} onChange={set("year")} placeholder="—" />
          <Field half label="Composer" value={f.composer} onChange={set("composer")} placeholder="—" />
        </div>

        <div className="mt-4 space-y-3">
          <Banner
            icon="info"
            title="Changes will be written to the audio file"
            text="Tags are saved inside the file itself when the format and permissions allow it. Otherwise LyraMusic keeps them in its local database."
          />
          {saved && (
            <div className="a-fade">
              <Banner tone="ok" icon="check" title="Saved" text="ID3v2.4 tags updated · library entry refreshed." />
            </div>
          )}
          <Card className="flex items-center gap-3">
            <span className="text-[var(--primary)]">
              <Icon name="sparkle" size={18} />
            </span>
            <span className="min-w-0 flex-1">
              <span className="t-title block">Fill automatically</span>
              <span className="t-meta block text-[var(--text-2)]">Look up this file online</span>
            </span>
            <Button size="sm" variant="secondary" onClick={() => go("enrichment")}>
              Search
            </Button>
          </Card>
        </div>
      </div>

      <div className="border-t border-[var(--divider)] bg-[var(--bg)] px-5 py-3">
        <div className="flex gap-2">
          <Button variant="secondary" full onClick={back}>
            Cancel
          </Button>
          <Button
            full
            onClick={() => {
              setSaved(true);
              notify("Tags written to file");
            }}
          >
            Save changes
          </Button>
        </div>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------- 20 ENRICHMENT */

const steps = [
  ["Audio file detected", "Cassette Loop 04.mp3"],
  ["Existing metadata analyzed", "2 of 7 tags present"],
  ["Online lookup", "3 sources queried"],
  ["Potential match found", "2 candidates"],
  ["Confidence evaluated", "Best match 64%"],
];

export function EnrichmentScreen() {
  const { back, go, notify, online } = useLyra();
  const [phase, setPhase] = useState<"running" | "uncertain" | "high">("uncertain");
  const [choice, setChoice] = useState(0);
  const done = phase === "high";

  return (
    <div className="px-5 pb-6">
      <AppBar title="Find information" subtitle="Metadata enrichment" onBack={back} />

      {!online && (
        <div className="mb-3">
          <Banner
            tone="warn"
            icon="offline"
            title="You are offline"
            text="Enrichment is paused. Everything else in your library keeps working."
            action="Retry when online"
          />
        </div>
      )}

      <Card pad={false} className="overflow-hidden">
        <div className="flex items-center gap-3 p-4">
          <div className="relative grid h-12 w-12 place-items-center rounded-[14px]" style={{ background: "var(--primary-soft)", color: "var(--primary)" }}>
            <Icon name={done ? "check" : "sparkle"} size={22} />
          </div>
          <div className="min-w-0 flex-1">
            <p className="t-h3">
              {phase === "running" ? "Analysing…" : done ? "Information found" : "Possible matches found"}
            </p>
            <p className="t-meta text-[var(--text-2)]">
              {phase === "running"
                ? "Comparing duration, title and folder name"
                : done
                ? "Automatically applied · confidence 96%"
                : "Review before applying · confidence 64%"}
            </p>
          </div>
          <Badge tone={done ? "ok" : phase === "running" ? "accent" : "warn"}>
            {done ? "High" : phase === "running" ? "…" : "Uncertain"}
          </Badge>
        </div>

        <div className="px-4 pb-4">
          <Progress value={done ? 100 : phase === "running" ? 62 : 86} />
        </div>

        <Divider />

        <ol className="space-y-0">
          {steps.map(([label, detail], i) => {
            const state = phase === "running" && i >= 3 ? "pending" : "done";
            return (
              <li key={label} className="flex items-center gap-3 px-4 py-2.5">
                <span
                  className="grid h-6 w-6 shrink-0 place-items-center rounded-full"
                  style={{
                    background: state === "done" ? "var(--primary)" : "var(--surface-2)",
                    color: state === "done" ? "var(--on-primary)" : "var(--text-3)",
                  }}
                >
                  <Icon name={state === "done" ? "check" : "clock"} size={12} />
                </span>
                <span className="min-w-0 flex-1">
                  <span className="t-title block">{label}</span>
                  <span className="t-meta block text-[var(--text-3)]">{detail}</span>
                </span>
              </li>
            );
          })}
          <li className="flex items-center gap-3 px-4 py-2.5">
            <span
              className="grid h-6 w-6 shrink-0 place-items-center rounded-full"
              style={{
                background: done ? "var(--success)" : "var(--surface-2)",
                color: done ? "#fff" : "var(--text-3)",
              }}
            >
              <Icon name={done ? "check" : "clock"} size={12} />
            </span>
            <span className="t-title flex-1">Metadata enriched</span>
          </li>
        </ol>
      </Card>

      {phase !== "running" && (
        <div className="mt-5">
          <SectionHead title="Candidates" action="Sources: 3" />
          <div className="space-y-2">
            {[
              { t: "Harbour Loop", a: "The Northern Arc", al: "Glass Harbor · 2022", c: 64, art: ART.glassHarbor },
              { t: "Cassette Loop", a: "Juno Marsh", al: "Paper Lanterns · 2018", c: 41, art: ART.paper },
            ].map((m, i) => (
              <button
                key={m.t}
                onClick={() => setChoice(i)}
                className="press flex w-full items-center gap-3 rounded-[var(--r-lg)] border p-3 text-left"
                style={{
                  borderColor: choice === i ? "var(--primary)" : "var(--divider)",
                  background: choice === i ? "var(--primary-soft)" : "var(--surface)",
                }}
              >
                <Art src={m.art} size={52} radius={12} seed={i} />
                <span className="min-w-0 flex-1">
                  <span className="t-title clamp-1 block">{m.t}</span>
                  <span className="t-meta clamp-1 block text-[var(--text-2)]">{m.a}</span>
                  <span className="t-meta clamp-1 block text-[var(--text-3)]">{m.al}</span>
                </span>
                <span className="text-right">
                  <span className="t-tech block text-[var(--text-2)]">{m.c}%</span>
                  <span className="t-label block text-[var(--text-3)]">match</span>
                </span>
              </button>
            ))}
          </div>

          <div className="mt-3">
            <Banner
              tone="warn"
              icon="shield"
              title="Nothing is overwritten without you"
              text="When confidence is low, LyraMusic asks first. Existing tags stay untouched until you apply a match."
            />
          </div>

          <div className="mt-4 flex gap-2">
            <Button variant="secondary" full onClick={() => go("metadata")}>
              Edit manually
            </Button>
            <Button
              full
              onClick={() => {
                setPhase("high");
                notify("Metadata applied");
              }}
            >
              Apply selected
            </Button>
          </div>
          <button onClick={() => setPhase("running")} className="press t-meta mt-3 w-full text-center text-[var(--text-3)]">
            Replay the analysis animation
          </button>
        </div>
      )}

      {phase === "running" && (
        <div className="mt-5 space-y-2">
          <div className="h-16 w-full overflow-hidden rounded-[var(--r-lg)] border border-[var(--divider)] bg-[var(--surface)] shimmer" />
          <div className="h-16 w-full overflow-hidden rounded-[var(--r-lg)] border border-[var(--divider)] bg-[var(--surface)] shimmer" />
          <button onClick={() => setPhase("uncertain")} className="press t-meta mt-2 w-full text-center text-[var(--text-3)]">
            Show results
          </button>
        </div>
      )}
    </div>
  );
}

/* ---------------------------------------------------------- 21 ARTWORK */

export function ArtworkScreen() {
  const { back, notify } = useLyra();
  const [selected, setSelected] = useState<"current" | "suggested">("suggested");
  const options = [ART.sodium, ART.ember, ART.paper, ART.softMachines];

  return (
    <div className="px-5 pb-6">
      <AppBar
        title="Artwork"
        subtitle="Cassette Loop 04"
        onBack={back}
        right={
          <Button size="sm" onClick={() => notify("Artwork applied")}>
            Apply
          </Button>
        }
      />

      <div className="grid grid-cols-2 gap-3 pt-1">
        {[
          { key: "current" as const, label: "Current", sub: "No embedded image", art: null },
          { key: "suggested" as const, label: "Suggested", sub: "Confidence 92%", art: ART.glassHarbor },
        ].map((o) => (
          <button
            key={o.key}
            onClick={() => setSelected(o.key)}
            className="press rounded-[var(--r-lg)] border p-2 text-left"
            style={{
              borderColor: selected === o.key ? "var(--primary)" : "var(--divider)",
              background: selected === o.key ? "var(--primary-soft)" : "transparent",
            }}
          >
            <Art src={o.art} size="100%" radius={14} />
            <div className="mt-2 flex items-center justify-between px-0.5">
              <div className="min-w-0">
                <p className="t-title clamp-1">{o.label}</p>
                <p className="t-meta clamp-1 text-[var(--text-3)]">{o.sub}</p>
              </div>
              {selected === o.key && (
                <span className="grid h-5 w-5 shrink-0 place-items-center rounded-full text-[var(--on-primary)]" style={{ background: "var(--primary)" }}>
                  <Icon name="check" size={11} />
                </span>
              )}
            </div>
          </button>
        ))}
      </div>

      <div className="mt-4 space-y-2">
        <Banner
          icon="shield"
          title="Automatic artwork needs high confidence"
          text="Images are downloaded and embedded only when the match is reliable. You can always change it."
        />
        <div className="flex gap-2">
          <Button full onClick={() => notify("Suggested artwork applied")}>
            Apply suggested
          </Button>
          <Button variant="secondary" full onClick={() => notify("Current artwork kept")}>
            Keep current
          </Button>
        </div>
      </div>

      <div className="mt-6">
        <SectionHead title="Other results" action="From 3 sources" />
        <div className="grid grid-cols-4 gap-2.5">
          {options.map((o, i) => (
            <button key={o} onClick={() => notify("Artwork selected")} className="press">
              <Art src={o} size="100%" radius={12} seed={i} />
            </button>
          ))}
        </div>
      </div>

      <div className="mt-5 space-y-2">
        <Button variant="secondary" full icon="image" onClick={() => notify("Gallery opened")}>
          Choose from photos
        </Button>
        <Button variant="ghost" full onClick={() => notify("Artwork removed")}>
          Remove artwork
        </Button>
        <p className="t-meta pt-1 text-center text-[var(--text-3)]">
          Downloaded artwork is stored on this device and stays available offline.
        </p>
      </div>
    </div>
  );
}
