#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const META_FILE = path.join(__dirname, '..', '.meta');
const WORKFLOWS_DIR = path.join(__dirname, '..', '.github', 'workflows');

function main() {
  const meta = JSON.parse(fs.readFileSync(META_FILE, 'utf8'));
  const projects = Object.keys(meta.projects);

  const workflows = fs.readdirSync(WORKFLOWS_DIR).filter(f => f.endsWith('.yml') || f.endsWith('.yaml'));

  if (workflows.length === 0) {
    console.log('No workflow files found in .github/workflows/ — nothing to sync.');
    return;
  }

  for (const project of projects) {
    const destDir = path.join(__dirname, '..', project, '.github', 'workflows');

    if (!fs.existsSync(path.join(__dirname, '..', project))) {
      console.log(`⏭  ${project}/ not cloned — skipping`);
      continue;
    }

    fs.mkdirSync(destDir, { recursive: true });

    for (const wf of workflows) {
      const src = path.join(WORKFLOWS_DIR, wf);
      const dest = path.join(destDir, wf);
      fs.copyFileSync(src, dest);
      console.log(`✓  ${wf} → ${project}/.github/workflows/${wf}`);
    }
  }

  console.log('\nDone. Review changes in each child repo before committing.');
}

main();
