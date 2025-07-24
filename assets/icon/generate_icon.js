// Simple Node.js script to generate app icon using Canvas API
// Run with: node generate_icon.js
// Requires: npm install canvas

const { createCanvas } = require('canvas');
const fs = require('fs');

function generateIcon() {
    const canvas = createCanvas(1024, 1024);
    const ctx = canvas.getContext('2d');
    
    // Create gradient background
    const gradient = ctx.createLinearGradient(0, 0, 1024, 1024);
    gradient.addColorStop(0, '#f8f9fa');
    gradient.addColorStop(1, '#e9ecef');
    
    // Draw circular background
    ctx.beginPath();
    ctx.arc(512, 512, 480, 0, 2 * Math.PI);
    ctx.fillStyle = gradient;
    ctx.fill();
    
    // Draw border
    ctx.beginPath();
    ctx.arc(512, 512, 480, 0, 2 * Math.PI);
    ctx.strokeStyle = '#dee2e6';
    ctx.lineWidth = 8;
    ctx.stroke();
    
    // Set shadow
    ctx.shadowColor = 'rgba(0, 0, 0, 0.15)';
    ctx.shadowBlur = 8;
    ctx.shadowOffsetX = 4;
    ctx.shadowOffsetY = 6;
    
    // Draw "Hello" text
    ctx.save();
    ctx.translate(512, 420);
    ctx.rotate(-0.15); // -8 degrees
    ctx.font = 'bold 140px Arial, sans-serif';
    ctx.fillStyle = '#FF3B30';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('Hello', 0, 0);
    ctx.restore();
    
    // Draw "World" text
    ctx.save();
    ctx.translate(512, 580);
    ctx.rotate(0.08); // 5 degrees
    ctx.font = 'bold 140px Arial, sans-serif';
    ctx.fillStyle = '#007AFF';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('World', 0, 0);
    ctx.restore();
    
    // Reset shadow
    ctx.shadowColor = 'transparent';
    ctx.shadowBlur = 0;
    ctx.shadowOffsetX = 0;
    ctx.shadowOffsetY = 0;
    
    // Draw sparkles
    ctx.font = '40px Arial';
    ctx.fillStyle = '#FFD700';
    
    // Sparkle positions
    const sparkles = [
        { x: 180, y: 200, rotation: 0.3, symbol: '✨' },
        { x: 844, y: 180, rotation: -0.4, symbol: '⭐' },
        { x: 160, y: 780, rotation: 0.5, symbol: '✨' },
        { x: 860, y: 820, rotation: -0.3, symbol: '⭐' }
    ];
    
    sparkles.forEach(sparkle => {
        ctx.save();
        ctx.translate(sparkle.x, sparkle.y);
        ctx.rotate(sparkle.rotation);
        ctx.fillText(sparkle.symbol, 0, 0);
        ctx.restore();
    });
    
    // Draw hearts
    ctx.font = '25px Arial';
    ctx.fillStyle = 'rgba(255, 105, 180, 0.6)';
    
    const hearts = [
        { x: 240, y: 340, rotation: 0.2 },
        { x: 780, y: 680, rotation: -0.2 }
    ];
    
    hearts.forEach(heart => {
        ctx.save();
        ctx.translate(heart.x, heart.y);
        ctx.rotate(heart.rotation);
        ctx.fillText('💖', 0, 0);
        ctx.restore();
    });
    
    // Save the image
    const buffer = canvas.toBuffer('image/png');
    fs.writeFileSync('./icon.png', buffer);
    console.log('Icon generated successfully as icon.png');
}

if (require.main === module) {
    generateIcon();
}

module.exports = { generateIcon };
