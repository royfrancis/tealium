-- hero-gallery.lua
-- Quarto filter to inject hero gallery HTML and JavaScript

-- Image extensions picked up from the gallery directory
local imageExtensions = {jpg = true, jpeg = true, png = true, gif = true, webp = true}

function Meta(meta)
  -- Check if hero-gallery is defined in metadata
  if meta['hero-gallery'] then
    local heroGallery = meta['hero-gallery']
    local imagePathMeta = heroGallery.images
    local imagePath = "assets/images/hero/"

    if imagePathMeta then
      imagePath = pandoc.utils.stringify(imagePathMeta)
    end

    -- Ensure imagePath ends with /
    if not imagePath:match("/$") then
      imagePath = imagePath .. "/"
    end

    -- Get list of image files in directory (a missing directory gives an empty list)
    local ok, entries = pcall(pandoc.system.list_directory, imagePath)
    if not ok then
      entries = {}
    end

    -- Keep image files only
    local imageFiles = {}
    for _, filename in ipairs(entries) do
      local extension = filename:match("%.([^.]+)$")
      if extension and imageExtensions[extension:lower()] then
        table.insert(imageFiles, filename)
      end
    end
    table.sort(imageFiles)

    -- Nothing to show, so skip the gallery markup and script
    if #imageFiles == 0 then
      quarto.log.warning("hero-gallery: no images found in '" .. imagePath .. "'")
      return meta
    end

    -- Build the gallery HTML
    -- The script below sets src from data-src so only the visible image is fetched first
    -- Keep the path on an <img> tag, since Quarto finds the files to copy to the output by scanning img src/data-src
    local galleryItems = {}
    for _, filename in ipairs(imageFiles) do
      local item = '<div class="child image-effect"><img alt="" data-src="' .. imagePath .. filename .. '"></div>'
      table.insert(galleryItems, item)
    end

    local html = '<div class="hero-container">\n<div class="hero-overlay"></div>\n<div class="hero-gallery">\n' .. table.concat(galleryItems, "\n") .. '\n</div> \n</div>'

    -- JavaScript for the gallery
    local script = [=[
<script>
// Hero gallery fade-through functionality
(function() {
  const gallery = document.querySelector('.hero-gallery');
  if (!gallery) return;
  const images = Array.from(gallery.querySelectorAll('.child'));
  if (images.length === 0) return;

  // Shuffle array using Fisher-Yates algorithm
  function shuffle(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }

  // Randomly shuffle the images
  const shuffledImages = shuffle(images);

  // Start loading a slide's image on first use, resolve once it has loaded (or failed)
  const loaders = new Map();
  function load(child) {
    if (!loaders.has(child)) {
      loaders.set(child, new Promise(resolve => {
        const img = child.querySelector('img');
        img.addEventListener('load', resolve);
        img.addEventListener('error', resolve);
        img.src = img.dataset.src;
      }));
    }
    return loaders.get(child);
  }

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  let currentIndex = 0;

  function fadeToNext() {
    // Keep the current image when the tab is hidden or reduced motion is preferred
    if (document.hidden || reducedMotion.matches) return;

    const current = shuffledImages[currentIndex];
    const nextIndex = (currentIndex + 1) % shuffledImages.length;
    const next = shuffledImages[nextIndex];

    // Fade only once the next image is available
    load(next).then(() => {
      // Toggle active class
      current.classList.remove('active');
      next.classList.add('active');

      currentIndex = nextIndex;
    });
  }

  // Show the first image as soon as it has loaded, other images are fetched after it
  load(shuffledImages[0]).then(() => {
    shuffledImages[0].classList.add('active');
    shuffledImages.slice(1).forEach(load);

    // Start the gallery rotation
    if (shuffledImages.length > 1) setInterval(fadeToNext, 5000);
  });
})();
</script>]=]

    -- Add the HTML and script right after the opening body tag
    quarto.doc.include_text("before-body", html .. "\n" .. script)
  end

  return meta
end
