#!/usr/bin/env node
/**
 * SEO Page Generator for Tafaseer App
 * 
 * Generates pre-rendered HTML pages with dynamic meta tags for:
 * - All 114 surahs
 * - First 10 ayahs of each surah
 * - All ayahs of popular surahs (Al-Fatiha, Ya-Sin, Ar-Rahman, Al-Mulk, Al-Kahf)
 */

const fs = require('fs');
const path = require('path');

// Configuration
const BUILD_DIR = path.join(__dirname, '..', 'build', 'web');
const ASSETS_DIR = path.join(__dirname, '..', 'assets', 'data');
const BASE_URL = 'https://tafaseer.web.app';

// Popular surahs to include all ayahs (not just first 10)
const POPULAR_SURAHS = [1, 18, 36, 55, 56, 67, 78, 112, 113, 114];

// Tafseer sources for keywords
const TAFSEER_SOURCES = [
    { arabic: 'الطبري', english: 'Tabari' },
    { arabic: 'ابن كثير', english: 'Ibn Kathir' },
    { arabic: 'السعدي', english: 'Saadi' },
    { arabic: 'القرطبي', english: 'Qurtubi' },
    { arabic: 'البغوي', english: 'Baghawi' },
    { arabic: 'ابن عاشور', english: 'Ibn Ashur' },
    { arabic: 'الكشاف', english: 'Kashaf' },
    { arabic: 'الرازي', english: 'Razi' },
];

// Arabic number converter
function toArabicNumeral(num) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return num.toString().split('').map(d => arabicNumerals[parseInt(d)]).join('');
}

// Load JSON data
function loadJSON(filePath) {
    try {
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (e) {
        console.error(`Error loading ${filePath}:`, e.message);
        return null;
    }
}

// Read the base index.html template
function getBaseTemplate() {
    const indexPath = path.join(BUILD_DIR, 'index.html');
    if (!fs.existsSync(indexPath)) {
        console.error('Error: build/web/index.html not found. Run "flutter build web" first.');
        process.exit(1);
    }
    return fs.readFileSync(indexPath, 'utf8');
}

// Generate HTML with dynamic meta tags
function generateSurahPage(template, surah, ayahs) {
    const title = `سورة ${surah.name_arabic} | Surah ${surah.name_english} - التفاسير`;
    const description = `اقرأ تفسير سورة ${surah.name_arabic} (${surah.name_english}) - ${surah.ayah_count} آية - ${surah.revelation_type}. تفاسير متعددة: الطبري، ابن كثير، السعدي، القرطبي، الكشاف، الرازي وغيرها.`;
    const keywords = `سورة ${surah.name_arabic}, ${surah.name_english}, تفسير, القرآن, ${TAFSEER_SOURCES.map(s => `تفسير ${s.arabic}`).join(', ')}`;
    const url = `${BASE_URL}/surah/${surah.id}`;

    // Get first ayah text for preview
    const firstAyah = ayahs && ayahs.length > 0 ? ayahs[0].text_arabic : '';

    return injectMetaTags(template, {
        title,
        description,
        keywords,
        url,
        ayahText: firstAyah,
        surah,
        ayahNumber: null
    });
}

function generateAyahPage(template, surah, ayah) {
    const arabicNum = toArabicNumeral(ayah.ayah_number);
    const title = `سورة ${surah.name_arabic} - آية ${arabicNum} | Surah ${surah.name_english} Ayah ${ayah.ayah_number} - التفاسير`;
    const description = `${ayah.text_arabic} - تفسير الآية ${ayah.ayah_number} من سورة ${surah.name_arabic}. اقرأ التفسير من الطبري، ابن كثير، السعدي والمزيد.`;
    const keywords = `آية ${ayah.ayah_number} سورة ${surah.name_arabic}, ${surah.name_english} ayah ${ayah.ayah_number}, quran ${surah.id}:${ayah.ayah_number}, تفسير, القرآن الكريم`;
    const url = `${BASE_URL}/surah/${surah.id}/ayah/${ayah.ayah_number}`;

    return injectMetaTags(template, {
        title,
        description,
        keywords,
        url,
        ayahText: ayah.text_arabic,
        surah,
        ayahNumber: ayah.ayah_number
    });
}

function injectMetaTags(template, data) {
    let html = template;

    // Replace title
    html = html.replace(
        /<title>.*?<\/title>/,
        `<title>${escapeHtml(data.title)}</title>`
    );

    // Replace meta name="title"
    html = html.replace(
        /<meta name="title" content=".*?">/,
        `<meta name="title" content="${escapeHtml(data.title)}">`
    );

    // Replace meta description
    html = html.replace(
        /<meta name="description"[\s\S]*?content=".*?">/,
        `<meta name="description" content="${escapeHtml(data.description)}">`
    );

    // Replace meta keywords
    html = html.replace(
        /<meta name="keywords"[\s\S]*?content=".*?">/,
        `<meta name="keywords" content="${escapeHtml(data.keywords)}">`
    );

    // Replace canonical URL
    html = html.replace(
        /<link rel="canonical" href=".*?">/,
        `<link rel="canonical" href="${data.url}">`
    );

    // Replace Open Graph tags
    html = html.replace(
        /<meta property="og:url" content=".*?">/,
        `<meta property="og:url" content="${data.url}">`
    );
    html = html.replace(
        /<meta property="og:title" content=".*?">/,
        `<meta property="og:title" content="${escapeHtml(data.title)}">`
    );
    html = html.replace(
        /<meta property="og:description"[\s\S]*?content=".*?">/,
        `<meta property="og:description" content="${escapeHtml(data.description)}">`
    );

    // Replace Twitter tags
    html = html.replace(
        /<meta property="twitter:url" content=".*?">/,
        `<meta property="twitter:url" content="${data.url}">`
    );
    html = html.replace(
        /<meta property="twitter:title" content=".*?">/,
        `<meta property="twitter:title" content="${escapeHtml(data.title)}">`
    );
    html = html.replace(
        /<meta property="twitter:description" content=".*?">/,
        `<meta property="twitter:description" content="${escapeHtml(data.description)}">`
    );

    // Add structured data for ayah pages
    if (data.ayahNumber) {
        const structuredData = generateStructuredData(data);
        html = html.replace(
            '</head>',
            `${structuredData}\n</head>`
        );
    }

    return html;
}

function generateStructuredData(data) {
    const jsonLd = {
        "@context": "https://schema.org",
        "@type": "Article",
        "name": data.title,
        "headline": `سورة ${data.surah.name_arabic} - آية ${toArabicNumeral(data.ayahNumber)}`,
        "description": data.description,
        "url": data.url,
        "mainEntityOfPage": data.url,
        "inLanguage": ["ar", "en"],
        "about": {
            "@type": "Thing",
            "name": "القرآن الكريم - The Holy Quran"
        },
        "isPartOf": {
            "@type": "Book",
            "name": `سورة ${data.surah.name_arabic}`,
            "alternateName": `Surah ${data.surah.name_english}`
        },
        "publisher": {
            "@type": "Organization",
            "name": "التفاسير - Tafaseer",
            "url": BASE_URL
        }
    };

    return `<script type="application/ld+json">\n${JSON.stringify(jsonLd, null, 2)}\n</script>`;
}

function escapeHtml(str) {
    return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function ensureDir(dirPath) {
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }
}

// Main execution
function main() {
    console.log('🕌 Tafaseer SEO Page Generator\n');

    // Load surahs
    const surahs = loadJSON(path.join(ASSETS_DIR, 'surahs.json'));
    if (!surahs) {
        console.error('Failed to load surahs.json');
        process.exit(1);
    }
    console.log(`✓ Loaded ${surahs.length} surahs`);

    // Get base template
    const template = getBaseTemplate();
    console.log('✓ Loaded base template (index.html)');

    let surahPagesCount = 0;
    let ayahPagesCount = 0;

    // Generate pages for each surah
    for (const surah of surahs) {
        // Load ayahs for this surah
        const ayahsPath = path.join(ASSETS_DIR, 'ayahs', `surah_${surah.id}.json`);
        const ayahs = loadJSON(ayahsPath) || [];

        // Create surah directory
        const surahDir = path.join(BUILD_DIR, 'surah', surah.id.toString());
        ensureDir(surahDir);

        // Generate surah page
        const surahHtml = generateSurahPage(template, surah, ayahs);
        fs.writeFileSync(path.join(BUILD_DIR, 'surah', `${surah.id}.html`), surahHtml);
        surahPagesCount++;

        // Determine how many ayahs to generate
        const isPopular = POPULAR_SURAHS.includes(surah.id);
        const ayahLimit = isPopular ? surah.ayah_count : Math.min(10, surah.ayah_count);

        // Generate ayah pages
        const ayahDir = path.join(surahDir, 'ayah');
        ensureDir(ayahDir);

        for (let i = 0; i < ayahLimit && i < ayahs.length; i++) {
            const ayah = ayahs[i];
            const ayahHtml = generateAyahPage(template, surah, ayah);
            fs.writeFileSync(path.join(ayahDir, `${ayah.ayah_number}.html`), ayahHtml);
            ayahPagesCount++;
        }

        process.stdout.write(`\r  Processing surah ${surah.id}/114...`);
    }

    console.log('\n');
    console.log(`✓ Generated ${surahPagesCount} surah pages`);
    console.log(`✓ Generated ${ayahPagesCount} ayah pages`);
    console.log(`\n🎉 Done! Pages are in: ${path.join(BUILD_DIR, 'surah')}`);
}

main();
