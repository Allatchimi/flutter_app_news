from yt_dlp import YoutubeDL

channel_url = 'https://www.youtube.com/@mrtvtchad/playlists'

def fetch_playlists(channel_url):
    ydl_opts = {
        'quiet': True,
        'extract_flat': True,
        'skip_download': True,
        'force_generic_extractor': False,
    }

    with YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(channel_url, download=False)
        if 'entries' in info:
            for playlist in info['entries']:
                print(f"Playlist : {playlist['title']}")
                print(f"Lien : https://www.youtube.com/playlist?list={playlist['id']}\n")

if __name__ == '__main__':
    fetch_playlists(channel_url)
