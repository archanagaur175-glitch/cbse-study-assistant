import csv
import json
import os
from shutil import copyfile

DEFAULT_PROFILE = {
    "name": "",
    "exam_goal": "boards",
    "daily_study_time": "1 hour",
    "difficulty_preference": "medium",
    "note_length_preference": "medium",
    "favorite_subjects": [],
    "weak_subjects": [],
    "chapter_order_preference": "weightage"
}

_csv_path = None
_profile_path = None
_init_done = False


def init_data_paths(app):
    global _csv_path, _profile_path, _init_done
    if _init_done:
        return

    user_dir = app.user_data_dir
    try:
        os.makedirs(user_dir, exist_ok=True)
    except Exception:
        pass

    _profile_path = os.path.join(user_dir, 'user_profile.json')

    bundle_dir = os.path.dirname(os.path.abspath(__file__))
    bundled_csv = os.path.join(bundle_dir, 'cbse_chapters.csv')
    _csv_path = os.path.join(user_dir, 'cbse_chapters.csv')

    if not os.path.exists(_csv_path):
        if os.path.exists(bundled_csv):
            try:
                copyfile(bundled_csv, _csv_path)
            except Exception:
                _csv_path = bundled_csv
        else:
            _csv_path = bundled_csv

    _init_done = True


def _read_csv(path):
    chapters = []
    try:
        with open(path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                ch = {}
                for key, value in row.items():
                    k = key.strip().lower() if key else ''
                    ch[k] = value.strip() if value else ''
                ch['chapter'] = ch.get('chapter', '').strip()
                try:
                    ch['pages'] = int(ch.get('pages', 0))
                except (ValueError, TypeError):
                    ch['pages'] = 0
                try:
                    ch['weightage'] = float(ch.get('weightage', 0))
                except (ValueError, TypeError):
                    ch['weightage'] = 0.0
                for field in ['key_formulas', 'detailed_notes', 'examples', 'practice_problems']:
                    if field not in ch:
                        ch[field] = ''
                chapters.append(ch)
        return chapters
    except Exception:
        return []


def load_chapters():
    global _csv_path
    if _csv_path and os.path.exists(_csv_path):
        return _read_csv(_csv_path)
    if _csv_path is None:
        bundle_dir = os.path.dirname(os.path.abspath(__file__))
        fallback = os.path.join(bundle_dir, 'cbse_chapters.csv')
        if os.path.exists(fallback):
            return _read_csv(fallback)
    return []


def _get_old_profile_path():
    bundle_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(bundle_dir, 'user_profile.json')


def load_profile():
    if _profile_path is None:
        return None
    try:
        with open(_profile_path, 'r', encoding='utf-8') as f:
            profile = json.load(f)
            merged = DEFAULT_PROFILE.copy()
            merged.update(profile)
            return merged
    except (FileNotFoundError, json.JSONDecodeError):
        old_path = _get_old_profile_path()
        if old_path and os.path.exists(old_path):
            try:
                with open(old_path, 'r', encoding='utf-8') as f:
                    profile = json.load(f)
                save_profile(profile)
                return profile
            except Exception:
                pass
        return None


def save_profile(profile):
    if _profile_path is None:
        return False
    try:
        with open(_profile_path, 'w', encoding='utf-8') as f:
            json.dump(profile, f, indent=2)
        return True
    except Exception:
        return False


def profile_exists():
    if _profile_path is None:
        return False
    return os.path.exists(_profile_path)
