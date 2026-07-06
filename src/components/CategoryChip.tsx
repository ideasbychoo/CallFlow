export default function CategoryChip({
  name,
  color,
}: {
  name: string;
  color?: string | null;
}) {
  const bg = color ?? "#94a3b8";
  return (
    <span
      className="inline-flex items-center gap-1.5 rounded-full px-2 py-0.5 text-xs font-medium"
      style={{ backgroundColor: bg + "22", color: bg }}
    >
      <span
        className="h-2 w-2 shrink-0 rounded-full"
        style={{ backgroundColor: bg }}
      />
      {name}
    </span>
  );
}
