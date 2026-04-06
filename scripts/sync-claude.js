#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const META_FILE = path.join(__dirname, '..', '.meta');
const FILES_TO_SYNC = ['CLAUDE.md', 'CONTRIBUTING.md'];

function main() {
  const meta = JSON.parse(fs.readFileSync(META_FILE, 'utf8'));
  const projects = Object.keys(meta.projects);

  for (const file of FILES_TO_SYNC) {
    const srcPath = path.join(__dirname, '..', file);
    if (!fs.existsSync(srcPath)) {
      console.log(`⏭  ${file} not found in meta-repo — skipping`);
      continue;
    }

    for (const project of projects) {
      const projectDir = path.join(__dirname, '..', project);

      if (!fs.existsSync(projectDir)) {
        console.log(`⏭  ${project}/ not cloned — skipping`);
        continue;
      }

      const destPath = path.join(projectDir, file);
      fs.copyFileSync(srcPath, destPath);
      console.log(`✓  ${file} → ${project}/${file}`);
    }
  }

  console.log('\nDone. Review changes in each child repo before committing.');
}

main();
