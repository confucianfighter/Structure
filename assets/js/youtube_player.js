// Is this the same event that triggers my update when user types? YES
document.addEventListener("DOMContentLoaded", () => {
    // Dynamically load the YouTube API script
    const script = document.createElement("script");
    script.src = "https://www.youtube.com/iframe_api";
    script.async = true;
    script.defer = true;
    document.head.appendChild(script);

    // Store all players in a global list
    window.players = window.players || [];
    window.stopAllVideos = () => {
        // Check if the players list is properly initialized and valid
        if (!Array.isArray(window.players)) {
            return "Error: 'players' is not initialized as an array.";
        }

        // Check if the players list is empty
        if (window.players.length === 0) {
            return "Error: No players found to stop.";
        }

        // Stop all videos
        try {
            window.players.forEach(player => player.stopVideo());
            return "Success: All videos have been stopped.";
        } catch (error) {
            return `Error: An exception occurred while stopping videos - ${error.message}`;
        }
    };
    // Define the YouTube API ready function globally
    window.onYouTubeIframeAPIReady = function () {
        console.log("YouTube API is ready!");

        const ytTags = document.querySelectorAll("youtube"); // Select all <youtube> tags
        if (ytTags.length === 0) {
            console.error("No <youtube> tags found in the document.");
            return "no youtube tags found.";
        }

        ytTags.forEach((ytTag, index) => {
            const videoId = ytTag.getAttribute("video-id");
            if (!videoId) {
                console.error(`No video ID provided in <youtube> tag at index ${index}.`);
                const errorMsg = document.createElement("p");
                errorMsg.textContent = `Error: No video ID provided for <youtube> at index ${index}.`;
                errorMsg.style.color = "red";
                ytTag.replaceWith(errorMsg);
                return `Error: No video ID provided for <youtube> at index ${index}.`;
            }

            const playerId = `youtube-player-${index}`; // Unique ID for each player
            const div = document.createElement("div");
            div.id = playerId;
            ytTag.replaceWith(div);

            // Initialize the YouTube player
            const player = new YT.Player(playerId, {
                videoId: videoId,
                playerVars: {
                    autoplay: 1, // Auto-play video
                    controls: 1, // Enable player controls
                    enablejsapi: 1, // Enable JS API for control
                    modestbranding: 0, // Minimal branding
                    rel: 0, // Disable related videos at the end
                    showinfo: 1, // Show video title and uploader info
                    fs: 1, // Enable fullscreen button
                },
                events: {
                    onReady: (event) => {
                        console.log(`YouTube Player ${index} is ready!`);
                    },
                    onError: (error) => {
                        console.error(`YouTube Player ${index} Error:`, error);
                    }
                }
            });

            // Store the player instance in the global list
            window.players.push(player);
        });
    };
});
