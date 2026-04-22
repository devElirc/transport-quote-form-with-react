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

  it("generates vehicle years from the current year down to 1980", () => {
    const html = readHtml();

    expect(html).toContain("for (let year = currentYear; year >= 1980; year -= 1)");
    expect(html).toContain('list="vehicle-year-options"');
  });

  it("loads mocked makes and dependent models in script data", () => {
    const html = readHtml();

    expect(html).toContain("const vehicleData = {");
    expect(html).toContain('Toyota: ["Camry", "Corolla", "RAV4", "Tacoma"]');
    expect(html).toContain('Tesla: ["Model 3", "Model Y", "Model S", "Model X"]');
    expect(html).toContain("populateModels");
  });
});
