import type { ReactNode } from "react";

export type IconName =
  | "home"
  | "library"
  | "search"
  | "playlist"
  | "settings"
  | "play"
  | "pause"
  | "next"
  | "prev"
  | "heart"
  | "queue"
  | "lyrics"
  | "eq"
  | "more"
  | "chevronLeft"
  | "chevronRight"
  | "chevronDown"
  | "shuffle"
  | "repeat"
  | "plus"
  | "edit"
  | "share"
  | "folder"
  | "note"
  | "disc"
  | "person"
  | "tag"
  | "clock"
  | "check"
  | "close"
  | "cloudDown"
  | "alert"
  | "grip"
  | "moon"
  | "sun"
  | "sparkle"
  | "offline"
  | "trash"
  | "image"
  | "speed"
  | "wave"
  | "shield"
  | "bell"
  | "info"
  | "filter"
  | "sort"
  | "grid"
  | "list"
  | "scan"
  | "volume";

const p: Record<IconName, ReactNode> = {
  home: <><path d="M4 10.4 12 4l8 6.4" /><path d="M6.2 9.6V20h11.6V9.6" /><path d="M10 20v-5.2h4V20" /></>,
  library: <><rect x="3.5" y="4.5" width="4" height="15" rx="1.4" /><rect x="9.5" y="4.5" width="4" height="15" rx="1.4" /><path d="m16.2 6.2 3.4 13.1" /></>,
  search: <><circle cx="10.8" cy="10.8" r="6.3" /><path d="m15.6 15.6 4 4" /></>,
  playlist: <><path d="M4 7h10" /><path d="M4 12h7" /><path d="M4 17h7" /><circle cx="17.5" cy="16.5" r="2.8" /><path d="M20.3 16.5V7l-3 .8" /></>,
  settings: <><circle cx="12" cy="12" r="3.1" /><path d="M12 3.5v2.2M12 18.3v2.2M20.5 12h-2.2M5.7 12H3.5M18 6l-1.6 1.6M7.6 16.4 6 18M18 18l-1.6-1.6M7.6 7.6 6 6" /></>,
  play: <path d="M7.5 5.3 18.6 12 7.5 18.7Z" />,
  pause: <><rect x="7.4" y="5.4" width="3.4" height="13.2" rx="1.3" /><rect x="13.2" y="5.4" width="3.4" height="13.2" rx="1.3" /></>,
  next: <><path d="M6.5 5.6 15.4 12l-8.9 6.4Z" /><rect x="16.6" y="5.4" width="2.4" height="13.2" rx="1.2" /></>,
  prev: <><path d="M17.5 5.6 8.6 12l8.9 6.4Z" /><rect x="5" y="5.4" width="2.4" height="13.2" rx="1.2" /></>,
  heart: <path d="M12 19.6s-7.6-4.4-7.6-9.6A4.2 4.2 0 0 1 12 7.3a4.2 4.2 0 0 1 7.6 2.7c0 5.2-7.6 9.6-7.6 9.6Z" />,
  queue: <><path d="M4 7h11" /><path d="M4 12h8" /><path d="M4 17h8" /><path d="M16 12.5h4.5" /><path d="M18.2 10.3 20.5 12.5l-2.3 2.2" /></>,
  lyrics: <><rect x="4.5" y="3.8" width="15" height="16.4" rx="3" /><path d="M8.2 8.6h7.6M8.2 12h7.6M8.2 15.4h4.6" /></>,
  eq: <><path d="M6.5 4v3.2M6.5 12.6V20M12 4v8.4M12 17.8V20M17.5 4v1.6M17.5 11V20" /><circle cx="6.5" cy="10" r="2.4" /><circle cx="12" cy="15.2" r="2.4" /><circle cx="17.5" cy="8.3" r="2.4" /></>,
  more: <><circle cx="12" cy="5.4" r="1.5" /><circle cx="12" cy="12" r="1.5" /><circle cx="12" cy="18.6" r="1.5" /></>,
  chevronLeft: <path d="m14.5 5.5-6.5 6.5 6.5 6.5" />,
  chevronRight: <path d="m9.5 5.5 6.5 6.5-6.5 6.5" />,
  chevronDown: <path d="m5.5 9.5 6.5 6.5 6.5-6.5" />,
  shuffle: <><path d="M3.8 6.6h3.1c3.6 0 4.1 10.8 7.8 10.8h5.5" /><path d="m17.5 14.4 3 3-3 3" /><path d="M3.8 17.4h3.1c1.6 0 2.5-2 3.2-4.3" /><path d="M14 9.2c.8-1.6 1.7-2.6 3-2.6h3.2" /><path d="m17.5 3.6 3 3-3 3" /></>,
  repeat: <><path d="M7.4 4.6h8.3a4 4 0 0 1 4 4v1.6" /><path d="m4.3 4.6 3 3-3 3" /><path d="M16.6 19.4H8.3a4 4 0 0 1-4-4v-1.6" /><path d="m19.7 19.4-3 3 3-3-3-3" /></>,
  plus: <><path d="M12 5.2v13.6" /><path d="M5.2 12h13.6" /></>,
  edit: <><path d="M4.6 19.4h3l9.6-9.6-3-3-9.6 9.6Z" /><path d="m14.9 4.1 3 3" /></>,
  share: <><path d="M12 15.6V4.4" /><path d="m8.4 7.6 3.6-3.2 3.6 3.2" /><path d="M6 12.4v6.2a1.2 1.2 0 0 0 1.2 1.2h9.6a1.2 1.2 0 0 0 1.2-1.2v-6.2" /></>,
  folder: <><path d="M3.8 7.4a1.6 1.6 0 0 1 1.6-1.6h3.4l2 2.2h7.8a1.6 1.6 0 0 1 1.6 1.6v8.6a1.6 1.6 0 0 1-1.6 1.6H5.4a1.6 1.6 0 0 1-1.6-1.6Z" /></>,
  note: <><path d="M9.4 17.6V5.8l9.2-1.8v11.6" /><ellipse cx="6.7" cy="17.9" rx="2.7" ry="2.3" /><ellipse cx="15.9" cy="15.9" rx="2.7" ry="2.3" /></>,
  disc: <><circle cx="12" cy="12" r="8.2" /><circle cx="12" cy="12" r="2.8" /><path d="M12 3.8v2.6M12 17.6v2.6" /></>,
  person: <><circle cx="12" cy="8.4" r="3.8" /><path d="M5 20a7 7 0 0 1 14 0" /></>,
  tag: <><path d="M4.4 11.2V5.4a1 1 0 0 1 1-1h5.8l8 8-6.8 6.8-8-8Z" /><circle cx="8.3" cy="8.3" r="1.3" /></>,
  clock: <><circle cx="12" cy="12" r="8.2" /><path d="M12 7.2V12l3.2 2" /></>,
  check: <path d="m5.4 12.4 4.3 4.3 9-9.4" />,
  close: <><path d="m6.4 6.4 11.2 11.2" /><path d="M17.6 6.4 6.4 17.6" /></>,
  cloudDown: <><path d="M7.4 16.4a3.6 3.6 0 0 1 .5-7.2 5 5 0 0 1 9.6.9 3.2 3.2 0 0 1-.6 6.3" /><path d="M12 11.6v7.8" /><path d="m9.2 16.8 2.8 2.8 2.8-2.8" /></>,
  alert: <><path d="M12 4.4 3.2 19.6h17.6Z" /><path d="M12 10v4.2" /><path d="M12 17.2h.01" /></>,
  grip: <><path d="M8.6 7.2h.01M15.4 7.2h.01M8.6 12h.01M15.4 12h.01M8.6 16.8h.01M15.4 16.8h.01" /></>,
  moon: <path d="M20 14.6A8.4 8.4 0 0 1 9.4 4 7.6 7.6 0 1 0 20 14.6Z" />,
  sun: <><circle cx="12" cy="12" r="4" /><path d="M12 3v2M12 19v2M21 12h-2M5 12H3M18.4 5.6 17 7M7 17l-1.4 1.4M18.4 18.4 17 17M7 7 5.6 5.6" /></>,
  sparkle: <><path d="m12 4 1.7 4.9L18.6 10l-4.9 1.7L12 16.6l-1.7-4.9L5.4 10l4.9-1.1Z" /><path d="m18.6 15.4.8 2.2 2.2.8-2.2.8-.8 2.2-.8-2.2-2.2-.8 2.2-.8Z" /></>,
  offline: <><path d="m3.5 3.5 17 17" /><path d="M7.4 16.4a3.6 3.6 0 0 1 .8-7.1" /><path d="M11 6.6a5 5 0 0 1 6.5 4.3 3.2 3.2 0 0 1 .9 6" /><path d="M9.2 16.4h7" /></>,
  trash: <><path d="M5.6 7h12.8" /><path d="M9.4 7V5.4a1 1 0 0 1 1-1h3.2a1 1 0 0 1 1 1V7" /><path d="M7 7v11.6a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V7" /><path d="M10.4 10.6v5.6M13.6 10.6v5.6" /></>,
  image: <><rect x="3.8" y="5" width="16.4" height="14" rx="2.6" /><circle cx="9" cy="10" r="1.6" /><path d="m5 17 4.4-4.2 3.4 3L16 13l3.4 3.2" /></>,
  speed: <><path d="M4.4 17.6a8.6 8.6 0 1 1 15.2 0" /><path d="m12 13.4 3.8-4" /><circle cx="12" cy="14.4" r="1.4" /></>,
  wave: <><path d="M3 12h2.2l1.6-5 2.2 11 2.2-14 2.2 17 2.2-9 1.6 5H21" /></>,
  shield: <><path d="M12 4 5.4 6.4v5.2c0 4 2.8 7 6.6 8.4 3.8-1.4 6.6-4.4 6.6-8.4V6.4Z" /><path d="m9.4 12 1.9 2 3.3-3.6" /></>,
  bell: <><path d="M6.8 10.4a5.2 5.2 0 0 1 10.4 0c0 4 1.6 5.4 1.6 5.4H5.2s1.6-1.4 1.6-5.4Z" /><path d="M10.2 19a2 2 0 0 0 3.6 0" /></>,
  info: <><circle cx="12" cy="12" r="8.2" /><path d="M12 11v5.2" /><path d="M12 8h.01" /></>,
  filter: <><path d="M4.4 6.4h15.2" /><path d="M7.2 12h9.6" /><path d="M10 17.6h4" /></>,
  sort: <><path d="M7 5.4v13.2" /><path d="m4 8.4 3-3 3 3" /><path d="M17 18.6V5.4" /><path d="m14 15.6 3 3 3-3" /></>,
  grid: <><rect x="4.2" y="4.2" width="6.4" height="6.4" rx="1.8" /><rect x="13.4" y="4.2" width="6.4" height="6.4" rx="1.8" /><rect x="4.2" y="13.4" width="6.4" height="6.4" rx="1.8" /><rect x="13.4" y="13.4" width="6.4" height="6.4" rx="1.8" /></>,
  list: <><path d="M4.4 6.6h15.2M4.4 12h15.2M4.4 17.4h15.2" /></>,
  scan: <><path d="M4.4 8.6V6a1.6 1.6 0 0 1 1.6-1.6h2.6M15.4 4.4H18A1.6 1.6 0 0 1 19.6 6v2.6M19.6 15.4V18a1.6 1.6 0 0 1-1.6 1.6h-2.6M8.6 19.6H6A1.6 1.6 0 0 1 4.4 18v-2.6" /><path d="M4.4 12h15.2" /></>,
  volume: <><path d="M5 9.6h3L12 6v12l-4-3.6H5Z" /><path d="M15.4 9.6a3.6 3.6 0 0 1 0 4.8" /></>,
};

export function Icon({
  name,
  size = 20,
  filled = false,
  className = "",
  strokeWidth = 1.7,
}: {
  name: IconName;
  size?: number;
  filled?: boolean;
  className?: string;
  strokeWidth?: number;
}) {
  const solid = filled || name === "play" || name === "pause";
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill={solid ? "currentColor" : "none"}
      stroke="currentColor"
      strokeWidth={solid ? 0 : strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden="true"
      focusable="false"
    >
      {p[name]}
    </svg>
  );
}
