"use client";

import { useState } from "react";
import { format, formatDistanceToNow } from "date-fns";
import { EditableText } from "./EditableField";
import StatusDropdown from "./StatusDropdown";
import CategoryChip from "./CategoryChip";
import CountryFlag from "./CountryFlag";
import type {
  Organisation,
  Status,
  Department,
  SeniorityLevel,
  Category,
  Country,
  SourceType,
  Source,
  Segment,
  StaffMember,
  EmailTemplate,
} from "@/types";
import {
  updateOrganisation,
  upsertStaffMember,
  addStaffMember,
  deleteStaffMember,
  upsertOfficeLocation,
  deleteOfficeLocation,
  deleteOrganisation,
  googleVoiceCallUrl,
  openInNewWindow,
  researchSearchUrl,
  resolveMergeTags,
  gmailComposeUrl,
} from "@/lib/data";

export default function OrganisationCard({
  org,
  statuses,
  departments,
  seniorityLevels,
  categories,
  countries,
  sourceTypes,
  sources,
  segments,
  emailTemplates,
  defaultExpanded = false,
  onChanged,
}: {
  org: Organisation;
  statuses: Status[];
  departments: Department[];
  seniorityLevels: SeniorityLevel[];
  categories: Category[];
  countries: Country[];
  sourceTypes: SourceType[];
  sources: Source[];
  segments: Segment[];
  emailTemplates: EmailTemplate[];
  defaultExpanded?: boolean;
  onChanged: () => void;
}) {
  const [expanded, setExpanded] = useState(defaultExpanded);
  const [showHistory, setShowHistory] = useState(false);

  async function save(fields: Partial<Organisation>) {
    await updateOrganisation(org.id, fields);
    onChanged();
  }

  const staffByCell = new Map<string, StaffMember[]>();
  const unassignedStaff: StaffMember[] = [];
  for (const person of org.staff ?? []) {
    if (!person.department_id || !person.seniority_id) {
      unassignedStaff.push(person);
      continue;
    }
    const key = `${person.department_id}::${person.seniority_id}`;
    if (!staffByCell.has(key)) staffByCell.set(key, []);
    staffByCell.get(key)!.push(person);
  }

  const sortedDepartments = [...departments].sort(
    (a, b) => a.sort_order - b.sort_order
  );
  const sortedSeniority = [...seniorityLevels].sort(
    (a, b) => a.sort_order - b.sort_order
  );

  async function addPerson(departmentId: string, seniorityId: string) {
    try {
      await addStaffMember({
        organisation_id: org.id,
        department_id: departmentId,
        seniority_id: seniorityId,
        full_name: "New person",
      });
      onChanged();
    } catch (err) {
      console.error(err);
      alert("Couldn't add the new person. Please try again.");
    }
  }

  async function addLocation() {
    await upsertOfficeLocation({
      organisation_id: org.id,
      location_name: "New location",
    });
    onChanged();
  }

  const sortedCategories = [...categories].sort((a, b) => a.name.localeCompare(b.name));
  const selectedCategory = categories.find((c) => c.id === org.category_id) ?? null;

  return (
    <div
      className="mb-4 rounded-xl border border-slate-200 bg-white shadow-sm"
      style={
        selectedCategory?.color
          ? { borderLeft: `4px solid ${selectedCategory.color}` }
          : undefined
      }
    >
      {/* Header row - always visible */}
      <div className="flex items-start justify-between gap-4 p-5">
        <button
          onClick={() => setExpanded((v) => !v)}
          className="mt-1 shrink-0 text-slate-400 hover:text-slate-700"
          aria-label={expanded ? "Collapse" : "Expand"}
        >
          {expanded ? "▾" : "▸"}
        </button>

        <div className="flex-1">
          <EditableText
            value={org.name}
            onSave={(v) => save({ name: v })}
            className="w-full rounded border border-transparent bg-transparent text-xl font-semibold text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
          />
          <div className="mt-1 flex flex-wrap items-center gap-2 text-sm text-slate-600">
            {selectedCategory && (
              <CategoryChip name={selectedCategory.name} color={selectedCategory.color} />
            )}
            <select
              value={org.category_id ?? ""}
              onChange={(e) => save({ category_id: e.target.value || null })}
              className="rounded border border-transparent bg-transparent text-sm text-slate-600 hover:border-slate-200 focus:border-slate-400 focus:outline-none"
            >
              <option value="">No category</option>
              {sortedCategories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
            <select
              value={org.segment_id ?? ""}
              onChange={(e) => save({ segment_id: e.target.value || null })}
              className="rounded border border-transparent bg-transparent text-sm text-slate-600 hover:border-slate-200 focus:border-slate-400 focus:outline-none"
            >
              <option value="">No segment</option>
              {[...segments]
                .sort((a, b) => a.name.localeCompare(b.name))
                .map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name}
                  </option>
                ))}
            </select>
            <span className="font-medium">· Similar to</span>
            <EditableText
              value={org.similar_to_client}
              onSave={(v) => save({ similar_to_client: v })}
              placeholder="client name"
              className="w-40 rounded border border-transparent bg-transparent text-sm hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
            />
          </div>
          <div className="mt-1 flex items-start gap-1 text-sm">
            <span className="font-medium text-slate-700">Angle:</span>
            <EditableText
              value={org.angle}
              onSave={(v) => save({ angle: v })}
              placeholder="Why Makerble is a good fit"
              multiline
              className="w-full flex-1 rounded border border-transparent bg-transparent text-sm text-slate-600 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
            />
          </div>
        </div>

        <div className="flex shrink-0 flex-col items-end gap-2">
          <StatusDropdown
            statuses={statuses}
            value={org.status_id}
            onChange={(statusId) => save({ status_id: statusId })}
          />
          <div className="text-right text-xs leading-relaxed text-slate-500">
            <div className="flex items-center justify-end gap-1">
              <CountryFlag country={org.country} />
              <select
                value={org.country ?? ""}
                onChange={(e) => save({ country: e.target.value || null })}
                className="rounded border border-transparent bg-transparent text-right text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:outline-none"
              >
                <option value="">No country</option>
                {[...countries]
                  .sort((a, b) => a.name.localeCompare(b.name))
                  .map((c) => (
                    <option key={c.id} value={c.name}>
                      {c.name}
                    </option>
                  ))}
              </select>
            </div>
            <div>
              Spotted:{" "}
              <EditableText
                value={org.date_spotted}
                onSave={(v) => save({ date_spotted: v })}
                className="inline w-24 rounded border border-transparent bg-transparent text-right text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
              />
            </div>
            {org.created_by && (
              <div className="text-slate-400" title="Who or what added this record">
                Added by: {org.created_by}
              </div>
            )}
            <div>
              Recent interaction:{" "}
              {org.last_interaction_at
                ? formatDistanceToNow(new Date(org.last_interaction_at), {
                    addSuffix: true,
                  })
                : "—"}
            </div>
            <button
              onClick={() => setShowHistory((v) => !v)}
              className="underline decoration-dotted hover:text-slate-700"
            >
              Call attempts: {org.call_attempts}
            </button>
          </div>
        </div>
      </div>

      {showHistory && (
        <div className="border-t border-slate-100 bg-slate-50 px-5 py-3 text-xs text-slate-600">
          <div className="mb-1 font-medium text-slate-700">History</div>
          {(org.status_history ?? [])
            .slice()
            .sort(
              (a, b) =>
                new Date(b.changed_at).getTime() -
                new Date(a.changed_at).getTime()
            )
            .map((h) => {
              const statusName =
                statuses.find((s) => s.id === h.status_id)?.name ?? "—";
              return (
                <div key={h.id}>
                  {statusName} — {format(new Date(h.changed_at), "d MMM, HH:mm")}
                </div>
              );
            })}
          {(org.status_history ?? []).length === 0 && <div>No history yet.</div>}
        </div>
      )}

      {!expanded ? null : (
        <div className="border-t border-slate-100 px-5 pb-5 pt-4">
          <div className="flex flex-col gap-6 lg:flex-row">
            {/* Staff grid */}
            <div className="flex-1 overflow-x-auto">
              <table className="w-full border-collapse text-sm">
                <thead>
                  <tr>
                    <th className="w-40 border-b border-slate-200 pb-2 text-left font-medium text-slate-500"></th>
                    {sortedSeniority.map((s) => (
                      <th
                        key={s.id}
                        className="border-b border-slate-200 pb-2 text-left font-medium text-slate-700"
                      >
                        {s.name}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {sortedDepartments.map((dept) => (
                    <tr key={dept.id} className="align-top">
                      <td className="border-b border-slate-100 py-3 pr-3 font-medium text-slate-700">
                        {dept.name}
                      </td>
                      {sortedSeniority.map((sen) => {
                        const key = `${dept.id}::${sen.id}`;
                        const people = staffByCell.get(key) ?? [];
                        return (
                          <td
                            key={sen.id}
                            className="border-b border-slate-100 py-3 pr-3"
                          >
                            <div className="space-y-3">
                              {people.map((p) => (
                                <StaffPersonEditor
                                  key={p.id}
                                  person={p}
                                  org={org}
                                  departments={departments}
                                  seniorityLevels={seniorityLevels}
                                  emailTemplates={emailTemplates}
                                  onChanged={onChanged}
                                />
                              ))}
                            </div>
                            <button
                              onClick={() => addPerson(dept.id, sen.id)}
                              className="mt-1 block text-xs text-slate-400 hover:text-slate-700"
                            >
                              + Add person
                            </button>
                            <button
                              onClick={() =>
                                openInNewWindow(
                                  researchSearchUrl(org.name, sen.name, dept.name)
                                )
                              }
                              className="mt-1 block text-xs text-slate-400 hover:text-slate-700"
                            >
                              🔎 Research
                            </button>
                          </td>
                        );
                      })}
                    </tr>
                  ))}
                </tbody>
              </table>

              {unassignedStaff.length > 0 && (
                <div className="mt-4">
                  <div className="mb-2 text-xs font-medium uppercase tracking-wide text-slate-400">
                    Other contacts
                  </div>
                  <div className="grid gap-3 sm:grid-cols-2">
                    {unassignedStaff.map((p) => (
                      <StaffPersonEditor
                        key={p.id}
                        person={p}
                        org={org}
                        departments={departments}
                        seniorityLevels={seniorityLevels}
                        emailTemplates={emailTemplates}
                        onChanged={onChanged}
                      />
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Right column: locations + links */}
            <div className="w-full shrink-0 space-y-4 text-sm lg:w-64">
              <div>
                <div className="mb-1 flex items-center justify-between">
                  <span className="font-medium text-slate-700">
                    Office locations
                  </span>
                  <button
                    onClick={addLocation}
                    className="text-xs text-slate-400 hover:text-slate-700"
                  >
                    + Add
                  </button>
                </div>
                <div className="space-y-2">
                  {(org.office_locations ?? []).map((loc) => (
                    <div
                      key={loc.id}
                      className="rounded border border-slate-100 p-2"
                    >
                      <EditableText
                        value={loc.location_name}
                        onSave={(v) =>
                          upsertOfficeLocation({
                            id: loc.id,
                            organisation_id: org.id,
                            location_name: v,
                            phone_number: loc.phone_number,
                          }).then(onChanged)
                        }
                        className="w-full rounded border border-transparent bg-transparent text-xs font-medium text-slate-600 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                      />
                      <div className="mt-1 flex items-center gap-2">
                        {loc.phone_number && (
                          <a
                            href={googleVoiceCallUrl(loc.phone_number)}
                            onClick={(e) => {
                              e.preventDefault();
                              openInNewWindow(googleVoiceCallUrl(loc.phone_number!));
                            }}
                            className="text-blue-600 hover:underline"
                          >
                            {loc.phone_number}
                          </a>
                        )}
                        <EditableText
                          value={loc.phone_number}
                          onSave={(v) =>
                            upsertOfficeLocation({
                              id: loc.id,
                              organisation_id: org.id,
                              location_name: loc.location_name,
                              phone_number: v,
                              availability: loc.availability,
                            }).then(onChanged)
                          }
                          placeholder="Phone number"
                          className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                        />
                        <button
                          onClick={() =>
                            deleteOfficeLocation(loc.id).then(onChanged)
                          }
                          className="ml-auto text-xs text-slate-300 hover:text-red-500"
                        >
                          ✕
                        </button>
                      </div>
                      <EditableText
                        value={loc.availability}
                        onSave={(v) =>
                          upsertOfficeLocation({
                            id: loc.id,
                            organisation_id: org.id,
                            location_name: loc.location_name,
                            phone_number: loc.phone_number,
                            availability: v,
                          }).then(onChanged)
                        }
                        placeholder="e.g. Mon–Fri 9am–1pm"
                        className="mt-1 w-full rounded border border-transparent bg-transparent text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                      />
                      <div className="mt-1 flex items-center gap-2">
                        {loc.website_url && (
                          <a
                            href={loc.website_url}
                            onClick={(e) => {
                              e.preventDefault();
                              openInNewWindow(loc.website_url!);
                            }}
                            className="truncate text-xs text-blue-600 hover:underline"
                          >
                            {loc.website_url}
                          </a>
                        )}
                      </div>
                      <EditableText
                        value={loc.website_url}
                        onSave={(v) =>
                          upsertOfficeLocation({
                            id: loc.id,
                            organisation_id: org.id,
                            location_name: loc.location_name,
                            phone_number: loc.phone_number,
                            availability: loc.availability,
                            website_url: v,
                          }).then(onChanged)
                        }
                        placeholder="Location website URL"
                        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                      />
                    </div>
                  ))}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <div className="font-medium text-slate-700">Source Type</div>
                  <select
                    value={org.source_type_id ?? ""}
                    onChange={(e) => save({ source_type_id: e.target.value || null })}
                    className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:outline-none"
                  >
                    <option value="">—</option>
                    {[...sourceTypes]
                      .sort((a, b) => a.sort_order - b.sort_order)
                      .map((t) => (
                        <option key={t.id} value={t.id}>{t.name}</option>
                      ))}
                  </select>
                </div>
                <div>
                  <div className="font-medium text-slate-700">Source</div>
                  <select
                    value={org.source_id ?? ""}
                    onChange={(e) => save({ source_id: e.target.value || null })}
                    className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:outline-none"
                  >
                    <option value="">—</option>
                    {[...sources]
                      .sort((a, b) => a.name.localeCompare(b.name))
                      .map((s) => (
                        <option key={s.id} value={s.id}>{s.name}</option>
                      ))}
                  </select>
                </div>
              </div>

              <LinkField
                label="Website"
                value={org.website}
                onSave={(v) => save({ website: v })}
              />
              <LinkField
                label="Organisation LinkedIn"
                value={org.linkedin}
                onSave={(v) => save({ linkedin: v })}
              />
              <LinkField
                label="Team page"
                value={org.team_page}
                onSave={(v) => save({ team_page: v })}
              />
              <LinkField
                label="Annual report"
                value={org.annual_report}
                onSave={(v) => save({ annual_report: v })}
              />
              <LinkField
                label="Impact report"
                value={org.impact_report}
                onSave={(v) => save({ impact_report: v })}
              />

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <div className="font-medium text-slate-700">Beneficiaries</div>
                  <EditableText
                    value={org.beneficiaries?.toString() ?? ""}
                    onSave={(v) =>
                      save({ beneficiaries: v.trim() ? Number(v) : null })
                    }
                    placeholder="e.g. 5000"
                    className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                  />
                </div>
                <div>
                  <div className="font-medium text-slate-700">Workers</div>
                  <EditableText
                    value={org.workers?.toString() ?? ""}
                    onSave={(v) =>
                      save({ workers: v.trim() ? Number(v) : null })
                    }
                    placeholder="staff/volunteers"
                    className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                  />
                </div>
              </div>

              <div>
                <div className="mb-1 font-medium text-slate-700">Notes</div>
                <EditableText
                  value={org.notes}
                  onSave={(v) => save({ notes: v })}
                  multiline
                  placeholder="Research / call notes"
                  className="w-full rounded border border-slate-200 bg-slate-50 px-2 py-1 text-xs hover:border-slate-300 focus:border-slate-400 focus:bg-white focus:outline-none"
                />
              </div>

              <button
                onClick={() => {
                  if (confirm(`Delete ${org.name}? This can't be undone.`)) {
                    deleteOrganisation(org.id).then(onChanged);
                  }
                }}
                className="text-xs text-slate-300 hover:text-red-500"
              >
                Delete organisation
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function LinkField({
  label,
  value,
  onSave,
}: {
  label: string;
  value: string | null | undefined;
  onSave: (v: string) => void;
}) {
  return (
    <div>
      <div className="font-medium text-slate-700">{label}</div>
      <div className="flex items-center gap-2">
        {value && (
          <a
            href={value}
            onClick={(e) => {
              e.preventDefault();
              openInNewWindow(value);
            }}
            className="truncate text-xs text-blue-600 hover:underline"
          >
            {value}
          </a>
        )}
      </div>
      <EditableText
        value={value}
        onSave={onSave}
        placeholder="https://…"
        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
    </div>
  );
}

function StaffPersonEditor({
  person,
  org,
  departments,
  seniorityLevels,
  emailTemplates,
  onChanged,
}: {
  person: StaffMember;
  org: Organisation;
  departments: Department[];
  seniorityLevels: SeniorityLevel[];
  emailTemplates: EmailTemplate[];
  onChanged: () => void;
}) {
  async function update(fields: Partial<StaffMember>) {
    await upsertStaffMember({ ...person, ...fields, id: person.id });
    onChanged();
  }

  function sendEmail(templateId: string) {
    const template = emailTemplates.find((t) => t.id === templateId);
    if (!template || !person.email) return;
    const departmentName = departments.find((d) => d.id === person.department_id)?.name;
    const seniorityName = seniorityLevels.find((s) => s.id === person.seniority_id)?.name;
    const subject = resolveMergeTags(template.subject, org, person, departmentName, seniorityName);
    const body = resolveMergeTags(template.body, org, person, departmentName, seniorityName);
    openInNewWindow(gmailComposeUrl(person.email, subject, body));
  }

  return (
    <div className="rounded border border-slate-100 p-2">
      <EditableText
        value={person.full_name}
        onSave={(v) => update({ full_name: v })}
        className="w-full rounded border border-transparent bg-transparent text-sm font-medium text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.job_title}
        onSave={(v) => update({ job_title: v })}
        placeholder="Job title"
        className="w-full rounded border border-transparent bg-transparent text-xs italic text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <div className="flex flex-wrap gap-x-2 text-xs">
        {person.email && (
          <a
            href={`mailto:${person.email}`}
            className="text-blue-600 hover:underline"
          >
            {person.email}
          </a>
        )}
        {person.email && emailTemplates.length > 0 && (
          <select
            value=""
            onChange={(e) => {
              if (e.target.value) sendEmail(e.target.value);
              e.target.value = "";
            }}
            className="rounded border border-slate-200 bg-slate-50 text-[11px] text-slate-500 hover:text-slate-700 focus:outline-none"
          >
            <option value="" disabled>✉️ Send…</option>
            {emailTemplates.map((t) => (
              <option key={t.id} value={t.id}>{t.title}</option>
            ))}
          </select>
        )}
        {person.linkedin && (
          <a
            href={person.linkedin}
            onClick={(e) => {
              e.preventDefault();
              openInNewWindow(person.linkedin!);
            }}
            className="text-blue-600 hover:underline"
          >
            LinkedIn
          </a>
        )}
        {person.direct_dial && (
          <a
            href={googleVoiceCallUrl(person.direct_dial)}
            onClick={(e) => {
              e.preventDefault();
              openInNewWindow(googleVoiceCallUrl(person.direct_dial!));
            }}
            className="text-blue-600 hover:underline"
          >
            {person.direct_dial}
          </a>
        )}
      </div>
      <EditableText
        value={person.email}
        onSave={(v) => update({ email: v })}
        placeholder="Email"
        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.linkedin}
        onSave={(v) => update({ linkedin: v })}
        placeholder="LinkedIn URL"
        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.direct_dial}
        onSave={(v) => update({ direct_dial: v })}
        placeholder="Direct dial"
        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.availability_notes}
        onSave={(v) => update({ availability_notes: v })}
        placeholder="Availability notes"
        className="w-full rounded border border-transparent bg-transparent text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.background_notes}
        onSave={(v) => update({ background_notes: v })}
        placeholder="Background notes"
        multiline
        className="w-full rounded border border-transparent bg-transparent text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.bio}
        onSave={(v) => update({ bio: v })}
        placeholder="Bio (from their website)"
        multiline
        className="w-full rounded border border-transparent bg-transparent text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <div className="flex items-center gap-2">
        {person.bio_url && (
          <a
            href={person.bio_url}
            onClick={(e) => {
              e.preventDefault();
              openInNewWindow(person.bio_url!);
            }}
            className="truncate text-xs text-blue-600 hover:underline"
          >
            {person.bio_url}
          </a>
        )}
      </div>
      <EditableText
        value={person.bio_url}
        onSave={(v) => update({ bio_url: v })}
        placeholder="Bio URL"
        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.conversation_notes}
        onSave={(v) => update({ conversation_notes: v })}
        placeholder="Conversation notes"
        multiline
        className="w-full rounded border border-transparent bg-transparent text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <button
        onClick={() => {
          if (confirm(`Remove ${person.full_name}?`)) {
            deleteStaffMember(person.id).then(onChanged);
          }
        }}
        className="mt-1 text-xs text-slate-300 hover:text-red-500"
      >
        Remove
      </button>
    </div>
  );
}
