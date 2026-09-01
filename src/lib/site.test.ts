import { describe, expect, it } from "vitest";
import { SITE_NAME } from "./site";

describe("SITE_NAME", () => {
  it("is The Agent Toolchain", () => {
    expect(SITE_NAME).toBe("The Agent Toolchain");
  });
});
