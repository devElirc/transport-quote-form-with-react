import { describe, it, expect } from "vitest";
import fs from "node:fs";
import path from "node:path";

const appHtmlPath = "/app/index.html";
const fallbackHtmlPath = path.resolve(process.cwd(), "..", "index.html");

function readHtml() {
  if (fs.existsSync(appHtmlPath)) {
    return fs.readFileSync(appHtmlPath, "utf8");
  }

  return fs.readFileSync(fallbackHtmlPath, "utf8");
}

describe("Transport quote form markup", () => {
  it("defines the two-step transport flow content", () => {
    const html = readHtml();

    expect(html).toContain("<title>Transport Quote Form</title>");
    expect(html).toContain("Transport car pickup and destination.");
    expect(html).toContain("Destination");
    expect(html).toContain("Vehicle");
    expect(html).toContain("VEHICLE DETAILS");
    expect(html).toContain("SAVE Calculate Cost");
  });

  it("includes the required fields and disabled vehicle model control", () => {
    const html = readHtml();

    expect(html).toMatch(/aria-label="Pickup"/);
    expect(html).toMatch(/aria-label="Delivery"/);
    expect(html).toMatch(/aria-label="Vehicle Year"/);
    expect(html).toMatch(/aria-label="Vehicle Make"/);
    expect(html).toMatch(/aria-label="Vehicle Model"/);
    expect(html).toMatch(/id="vehicle-model"[\s\S]*disabled/);
  });

  it("includes the expected validation copy and year list hook", () => {
    const html = readHtml();

    expect(html).toContain("Please enter both pickup and delivery locations.");
    expect(html).toContain('list="vehicle-year-options"');
  });

  it("contains mocked vehicle options and a dependent model control", () => {
    const html = readHtml();

    expect(html).toContain("Toyota");
    expect(html).toContain("Camry");
    expect(html).toContain("Corolla");
    expect(html).toContain("RAV4");
    expect(html).toContain("Tacoma");
    expect(html).toMatch(/vehicle-model/);
  });
});
