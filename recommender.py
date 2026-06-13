import re


def calculate_recovery_time(pages):
    return round(pages * 0.12 * 8, 1)


def search_chapters(chapters, query):
    if not query or not query.strip():
        return chapters
    q = query.strip().lower()
    results = []
    for ch in chapters:
        chapter_name = ch.get('chapter', '').lower()
        subject = ch.get('subject', '').lower()
        if q in chapter_name or q in subject:
            results.append(ch)
    return results


def get_daily_recommendation(chapters, profile):
    if not chapters:
        return None
    scored = _score_chapters(chapters, profile)
    if not scored:
        return chapters[0] if chapters else None
    best = scored[0]
    return best


def get_recommendations(chapters, profile, count=5):
    if not chapters:
        return []
    if not profile:
        return chapters[:count]
    scored = _score_chapters(chapters, profile)
    return scored[:count]


def _score_chapters(chapters, profile):
    weak_subjects = [s.strip().lower() for s in profile.get('weak_subjects', []) if s]
    difficulty = profile.get('difficulty_preference', 'medium').lower()
    daily_time = profile.get('daily_study_time', '1 hour')
    exam_goal = profile.get('exam_goal', 'boards').lower()
    note_pref = profile.get('note_length_preference', 'medium').lower()
    fav_subjects = [s.strip().lower() for s in profile.get('favorite_subjects', []) if s]

    time_minutes = _parse_time(daily_time)

    scored = []
    for ch in chapters:
        score = 0.0
        weightage = ch.get('weightage', 0)
        pages = ch.get('pages', 0)
        chapter_lower = ch.get('chapter', '').lower()
        subject = ch.get('subject', '').lower()

        score += weightage * 2.0

        if exam_goal == 'boards':
            score += weightage * 2.5
            score += max(0, 30 - pages) * 0.3
        elif exam_goal in ('competitive', 'jee', 'neet'):
            score += pages * 0.8
            score += weightage * 1.0

        if subject in weak_subjects:
            score += 25.0
        if subject in fav_subjects:
            score += 10.0

        if time_minutes <= 60:
            estimated_time = pages * 2.5
            if estimated_time <= time_minutes:
                score += 15.0
            else:
                score += max(0, 15.0 - (estimated_time - time_minutes) * 0.3)
        elif time_minutes >= 120:
            score += pages * 0.5

        if difficulty == 'easy' and pages <= 10:
            score += 8.0
        elif difficulty == 'hard' and pages >= 14:
            score += 8.0

        if note_pref == 'short' and pages <= 10:
            score += 5.0
        elif note_pref == 'detailed' and pages >= 12:
            score += 5.0

        recovery = calculate_recovery_time(pages)
        scored.append((score, ch, recovery))

    scored.sort(key=lambda x: x[0], reverse=True)
    return [(ch, rec) for _, ch, rec in scored]


def _parse_time(time_str):
    if not time_str:
        return 60
    try:
        time_str = str(time_str).lower()
        nums = re.findall(r'\d+', time_str)
        if not nums:
            return 60
        val = int(nums[0])
        if 'hour' in time_str:
            return val * 60
        return val
    except (ValueError, TypeError):
        return 60


def get_chapters_by_subject(chapters, subject):
    if not subject:
        return []
    s = subject.strip().lower()
    return [ch for ch in chapters if ch.get('subject', '').lower() == s]


def get_priority_topics(chapters, profile, count=3):
    weak = [s.strip().lower() for s in profile.get('weak_subjects', []) if s]
    weak_chapters = [ch for ch in chapters if ch.get('subject', '').lower() in weak]
    if weak_chapters:
        return _score_chapters(weak_chapters, profile)[:count]
    return get_recommendations(chapters, profile, count)
