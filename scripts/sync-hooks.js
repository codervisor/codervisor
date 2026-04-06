#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const META_FILE = path.join(__dirname, '..', '.meta');
const HOOKS_DIR = path.join(__dirname, '..', 'hooks');

function copyDirRecursive(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    if (entry.name === '.gitkeep') continue;
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDirRecursive(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
      console.log(`✓  ${entry.name} → ${path.relative(path.join(__dirname, '..'), destPath)}`);
    }
  }
}

function main() {
  const meta = JSON.parse(fs.readFileSync(META_FILE, 'utf8'));
  const projects = Object.keys(meta.projects);

  const hookFiles = fs.readdirSync(HOOKS_DIR).filter(f => f !== '.gitkeep');
  if (hookFiles.length === 0) {
    console.log('No hook files found in hooks/ — nothing to sync.');
    return;
  }

  for (const project of projects) {
    const projectDir = path.join(__dirname, '..', project);

    if (!fs.existsSync(projectDir)) {
      console.log(`⏭  ${project}/ not cloned — skipping`);
      continue;
    }

    const destDir = path.join(projectDir, 'hooks');
    copyDirRecursive(HOOKS_DIR, destDir);
  }

  console.log('\nDone. Review changes in each child repo before committing.');
}

main();
