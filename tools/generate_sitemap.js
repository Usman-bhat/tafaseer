#!/usr/bin/env node
/**
 * Enhanced Sitemap Generator for Tafaseer App
 * 
 * Generates sitemap.xml with:
 * - All 114 surah pages
 * - First 10 ayahs of each surah  
 * - All ayahs of popular surahs
 */

const fs = require('fs');
const path = require('path');

const ASSETS_DIR = path.join(__dirname, '..', 'assets', 'data');
const OUTPUT_PATH = path.join(__dirname, '..', 'web', 'sitemap.xml');
const BASE_URL = 'https://tafaseer.web.app';
const LAST_MOD = new Date().toISOString().split('T')[0];

// Popular surahs with all ayahs included
const POPULAR_SURAHS = [1, 18, 36, 55, 56, 67, 78, 112, 113, 114];

function loadJSON(filePath) {
    try {
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (e) {
        console.error(`Error loading ${filePath}:`, e.message);
        return null;
    }
}

function main() {
    console.log('🗺️  Enhanced Sitemap Generator\n');

    const surahs = loadJSON(path.join(ASSETS_DIR, 'surahs.json'));
    if (!surahs) {
        console.error('Failed to load surahs.json');
        process.exit(1);
    }

    let xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xhtml="http://www.w3.org/1999/xhtml">
  
  <!-- Homepage -->
  <url>
    <loc>${BASE_URL}/</loc>
    <lastmod>${LAST_MOD}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  
  <!-- Surah List -->
  <url>
    <loc>${BASE_URL}/surahs</loc>
    <lastmod>${LAST_MOD}</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.9</priority>
  </url>
  
  <!-- Search -->
  <url>
    <loc>${BASE_URL}/search</loc>
    <lastmod>${LAST_MOD}</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
`;

    let surahCount = 0;
    let ayahCount = 0;

    // Add surah and ayah pages
    for (const surah of surahs) {
        const ayahsPath = path.join(ASSETS_DIR, 'ayahs', `surah_${surah.id}.json`);
        const ayahs = loadJSON(ayahsPath) || [];

        // Determine priority based on surah popularity
        const isPopular = POPULAR_SURAHS.includes(surah.id);
        const surahPriority = isPopular ? '0.9' : (surah.id <= 20 ? '0.8' : '0.7');

        // Add surah page
        xml += `
  <!-- Surah ${surah.id}: ${surah.name_english} -->
  <url>
    <loc>${BASE_URL}/surah/${surah.id}</loc>
    <lastmod>${LAST_MOD}</lastmod>
    <changefreq>monthly</changefreq>
    <priority>${surahPriority}</priority>
  </url>
`;
        surahCount++;

        // Add ayah pages
        const ayahLimit = isPopular ? surah.ayah_count : Math.min(10, surah.ayah_count);

        for (let i = 0; i < ayahLimit && i < ayahs.length; i++) {
            const ayah = ayahs[i];
            const ayahPriority = isPopular ? '0.8' : '0.6';

            xml += `  <url>
    <loc>${BASE_URL}/surah/${surah.id}/ayah/${ayah.ayah_number}</loc>
    <lastmod>${LAST_MOD}</lastmod>
    <changefreq>monthly</changefreq>
    <priority>${ayahPriority}</priority>
  </url>
`;
            ayahCount++;
        }

        process.stdout.write(`\r  Processing surah ${surah.id}/114...`);
    }

    xml += `
</urlset>
`;

    // Write sitemap
    fs.writeFileSync(OUTPUT_PATH, xml);

    console.log('\n');
    console.log(`✓ Added ${surahCount} surah URLs`);
    console.log(`✓ Added ${ayahCount} ayah URLs`);
    console.log(`✓ Total: ${surahCount + ayahCount + 3} URLs`);
    console.log(`\n🎉 Sitemap saved to: ${OUTPUT_PATH}`);
}

main();
