import os
import json
import time
from typing import Dict

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from fastapi.concurrency import run_in_threadpool

from yt_dlp import YoutubeDL
from apscheduler.schedulers.background import BackgroundScheduler

app = FastAPI()

# Chemins et durée du cache
CACHE_DIR = "cache"
PLAYLISTS_CACHE = os.path.join(CACHE_DIR, "playlists.json")
PLAYLIST_VIDEOS_CACHE = os.path.join(CACHE_DIR, "playlist_videos.json")
CACHE_DURATION = 3600 * 6  # 6 heures

# ------------------ Gestion du Cache ------------------

def load_cache(path: str) -> Dict:
    """Chargement sécurisé du cache"""
    if os.path.exists(path):
        try:
            with open(path, "r", encoding="utf-8") as f:
                content = f.read().strip()
                if not content:
                    return {}
                return json.loads(content)
        except json.JSONDecodeError:
            print(f"⚠️ Cache corrompu : {path}. Suppression.")
            os.remove(path)
    return {}

def save_cache(path: str, data: Dict):
    """Sauvegarde propre du cache"""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

# ------------------ Accueil ------------------

@app.get("/")
def home():
    return {"message": "Bienvenue dans l'API YouTube Scraper"}

# ------------------ Récupération des Playlists ------------------

@app.get("/playlists")
async def fetch_playlists(refresh: bool = False):
    return await run_in_threadpool(_fetch_playlists, refresh)

def _fetch_playlists(refresh: bool = False):
    now = time.time()
    cache = load_cache(PLAYLISTS_CACHE)

    if not refresh and cache and now - cache.get("timestamp", 0) < CACHE_DURATION:
        return {"playlists": cache["data"]}

    channel_url = "https://www.youtube.com/@mrtvtchad/playlists"
    ydl_opts = {
        'quiet': True,
        'extract_flat': True,
        'skip_download': True,
        'ignoreerrors': True
    }

    try:
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(channel_url, download=False)
            playlists = []
            if 'entries' in info:
                for playlist in info['entries']:
                    if playlist is None:
                        continue
                    playlists.append({
                        "title": playlist.get("title", "Sans titre"),
                        "id": playlist.get("id"),
                        "url": f"https://www.youtube.com/playlist?list={playlist.get('id')}",
                        "description": playlist.get("description", ""),
                        "thumbnail": playlist.get("thumbnails", [{}])[-1].get("url", None)
                    })
        save_cache(PLAYLISTS_CACHE, {"timestamp": now, "data": playlists})
        return {"playlists": playlists}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

# ------------------ Récupération des vidéos d'une playlist ------------------

@app.get("/playlist_videos")
async def fetch_videos_from_playlist(url: str, refresh: bool = False):
    return await run_in_threadpool(_fetch_videos_from_playlist, url, refresh)

def _fetch_videos_from_playlist(url: str, refresh: bool = False):
    now = time.time()
    try:
        playlist_id = url.split("list=")[-1].split("&")[0]
    except Exception:
        return JSONResponse(status_code=400, content={"error": "URL invalide"})

    all_cache = load_cache(PLAYLIST_VIDEOS_CACHE)
    cache = all_cache.get(playlist_id, {})

    if not refresh and cache and now - cache.get("timestamp", 0) < CACHE_DURATION:
        return {"videos": cache["data"]}

    ydl_opts = {
        'quiet': True,
        'extract_flat': False,
        'skip_download': True,
        'ignoreerrors': True
    }

    try:
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            videos = []
            if 'entries' in info:
                for video in info['entries']:
                    if video is None or video.get("id") is None or "unavailable" in video.get("title", "").lower():
                        continue
                    videos.append({
                        "title": video.get("title", "Sans titre"),
                        "id": video.get("id"),
                        "url": f"https://www.youtube.com/watch?v={video.get('id')}",
                        "description": video.get("description", ""),
                        "thumbnail": f"https://i.ytimg.com/vi/{video.get('id')}/hqdefault.jpg"
                    })
        all_cache[playlist_id] = {"timestamp": now, "data": videos}
        save_cache(PLAYLIST_VIDEOS_CACHE, all_cache)
        return {"videos": videos}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

# ------------------ Rafraîchissement manuel ------------------

@app.post("/refresh_all")
def refresh_all_data():
    _fetch_playlists(refresh=True)
    all_cache = load_cache(PLAYLISTS_CACHE)
    for playlist in all_cache.get("data", []):
        url = playlist["url"]
        try:
            _fetch_videos_from_playlist(url=url, refresh=True)
        except:
            continue
    return {"status": "Mise à jour complète effectuée"}

# ------------------ Rafraîchissement automatique ------------------

def refresh_all():
    print("🔄 Mise à jour automatique des playlists...")
    _fetch_playlists(refresh=True)
    all_cache = load_cache(PLAYLISTS_CACHE)
    for playlist in all_cache.get("data", []):
        url = playlist["url"]
        try:
            _fetch_videos_from_playlist(url=url, refresh=True)
        except:
            continue

scheduler = BackgroundScheduler()
scheduler.add_job(refresh_all, 'interval', hours=24)
scheduler.start()
