#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const META_FILE = path.join(__dirname, '..', '.meta');
const CALLERS_DIR = path.join(__dirname, '..', 'templates', 'callers');

// Map project names to their CI caller template
const PROJECT_TYPE = {
  stiglab: 'rust',
  ising: 'rust',
  synodic: 'typescript',
  telegramable: 'typescript',
};

function main() {
  const meta = JSON.parse(fs.readFileSync(META_FILE, 'utf8'));
  const projects = Object.keys(meta.projects);

  for (const project of projects) {
    const projectDir = path.join(__dirname, '..', project);
    if (!fs.existsSync(projectDir)) {
      console.log(`⏭  ${project}/ not present — skipping`);
      continue;
    }

    const type = PROJECT_TYPE[project];
    if (!type) {
      console.log(`⏭  ${project} has no CI template mapping — skipping`);
      continue;
    }

    const src = path.join(CALLERS_DIR, `ci.yml.${type}`);
    if (!fs.existsSync(src)) {
      console.log(`⏭  Template ci.yml.${type} not found — skipping`);
      continue;
    }

    const destDir = path.join(projectDir, '.github', 'workflows');
    fs.mkdirSync(destDir, { recursive: true });

    const dest = path.join(destDir, 'ci.yml');
    fs.copyFileSync(src, dest);
    console.log(`✓  ci.yml (${type}) → ${project}/.github/workflows/ci.yml`);
  }

  console.log('\nDone. Review changes in each child repo before committing.');
}

main();
