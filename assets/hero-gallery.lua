-- hero-gallery.lua
-- Quarto filter to inject hero gallery HTML and JavaScript

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
    
    -- Get list of image files in directory
    local handle = io.popen('ls "' .. imagePath .. '" 2>/dev/null')
    local result = handle:read("*a")
    handle:close()
    
    -- Parse image files (common image extensions)
    local imageFiles = {}
    for filename in result:gmatch("[^\r\n]+") do
      if filename:match("%.jpg$") or filename:match("%.jpeg$") or 
         filename:match("%.png$") or filename:match("%.gif$") or 
         filename:match("%.webp$") then
        table.insert(imageFiles, filename)
      end
    end
    
    -- Build the gallery HTML
    local galleryItems = {}
    for _, filename in ipairs(imageFiles) do
      local item = '<div class="child image-effect"><img src="' .. imagePath .. filename .. '"></div>'
      table.insert(galleryItems, item)
    end
    
    local html = '<div class="hero-container">\n<div class="hero-overlay"></div>\n<div class="hero-gallery">\n' .. table.concat(galleryItems, "\n") .. '\n</div> \n</div>'
    
    -- JavaScript for the gallery
    local script = [=[
<script>
// Hero gallery fade-through functionality
(function() {
  const gallery = document.querySelector('.hero-gallery');
  const images = Array.from(gallery.querySelectorAll('.child'));
  
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
  
  // Wait for images to load before starting
  Promise.all(
    shuffledImages.map(child => {
      const img = child.querySelector('img');
      if (img.complete) return Promise.resolve();
      return new Promise(resolve => {
        img.addEventListener('load', resolve);
        img.addEventListener('error', resolve);
      });
    })
  ).then(() => {
    // Set first image as active after all images loaded
    shuffledImages[0].classList.add('active');
    
    let currentIndex = 0;
    
    function fadeToNext() {
      const current = shuffledImages[currentIndex];
      const nextIndex = (currentIndex + 1) % shuffledImages.length;
      const next = shuffledImages[nextIndex];
      
      // Toggle active class
      current.classList.remove('active');
      next.classList.add('active');
      
      currentIndex = nextIndex;
    }
    
    // Start the gallery rotation
    setInterval(fadeToNext, 5000);
  });
})();
</script>]=]
    
    -- Add the HTML and script to header-includes
    local headerIncludes = meta['header-includes']
    if not headerIncludes then
      headerIncludes = pandoc.MetaList{}
    end
    
    -- Convert to MetaList if it's not already
    if headerIncludes.t ~= 'MetaList' then
      headerIncludes = pandoc.MetaList{headerIncludes}
    end
    
    -- Add our HTML and script as RawBlocks
    table.insert(headerIncludes, pandoc.MetaBlocks{pandoc.RawBlock('html', html)})
    table.insert(headerIncludes, pandoc.MetaBlocks{pandoc.RawBlock('html', script)})
    
    meta['header-includes'] = headerIncludes
  end
  
  return meta
end
