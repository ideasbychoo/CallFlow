"use client";

import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import type { Status } from "@/types";

export default function Sidebar({ statuses }: { statuses: Status[] }) {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const router = useRouter();
  const activeStatusId = searchParams.get("status");

  async function handleLogout() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  }

  const sorted = [...statuses].sort((a, b) => a.sort_order - b.sort_order);

  return (
    <aside className="flex h-screen w-64 shrink-0 flex-col justify-between overflow-y-auto border-r border-slate-200 bg-white px-5 py-6">
      <div>
        <Link
          href="/call-list"
          className={`block text-lg font-semibold ${
            pathname === "/call-list" && !activeStatusId
              ? "text-slate-900"
              : "text-slate-700 hover:text-slate-900"
          }`}
        >
          Call List
        </Link>

        <ul className="mt-2 mb-6 space-y-1">
          {sorted.map((status) => (
            <li key={status.id}>
              <Link
                href={`/call-list?status=${status.id}`}
                className={`block rounded px-2 py-1 text-sm ${
                  activeStatusId === status.id
                    ? "bg-slate-100 font-medium text-slate-900"
                    : "text-slate-600 hover:bg-slate-50"
                }`}
              >
                {status.name}
              </Link>
            </li>
          ))}
        </ul>

        <Link
          href="/pipeline"
          className={`block text-lg font-semibold ${
            pathname === "/pipeline" ? "text-slate-900" : "text-slate-700 hover:text-slate-900"
          }`}
        >
          Pipeline
        </Link>

        <Link
          href="/organisations"
          className={`mt-6 block text-lg font-semibold ${
            pathname === "/organisations" ? "text-slate-900" : "text-slate-700 hover:text-slate-900"
          }`}
        >
          Organisations
        </Link>

        <Link
          href="/staff"
          className={`block text-lg font-semibold ${
            pathname === "/staff" ? "text-slate-900" : "text-slate-700 hover:text-slate-900"
          }`}
        >
          Staff
        </Link>

        <Link
          href="/reporting"
          className={`mt-6 block text-lg font-semibold ${
            pathname === "/reporting" ? "text-slate-900" : "text-slate-700 hover:text-slate-900"
          }`}
        >
          Reporting
        </Link>

        <Link
          href="/sources"
          className={`block text-lg font-semibold ${
            pathname === "/sources" ? "text-slate-900" : "text-slate-700 hover:text-slate-900"
          }`}
        >
          Sources
        </Link>

        <Link
          href="/settings"
          className={`mt-6 block text-lg font-semibold ${
            pathname === "/settings" ? "text-slate-900" : "text-slate-700 hover:text-slate-900"
          }`}
        >
          Settings
        </Link>
      </div>

      <button
        onClick={handleLogout}
        className="text-left text-lg font-semibold text-slate-700 hover:text-slate-900"
      >
        Logout
      </button>
    </aside>
  );
}
