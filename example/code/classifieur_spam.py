"""Classifieur de messages indésirables très simplifié (à but pédagogique)."""

MOTS_SUSPECTS = {"gratuit", "gagnant", "urgent", "cadeau", "cliquez"}


def score_spam(message: str) -> float:
    """Retourne la proportion de mots suspects dans le message."""
    mots = message.lower().split()
    if not mots:
        return 0.0
    suspects = sum(1 for mot in mots if mot.strip(".,!?") in MOTS_SUSPECTS)
    return suspects / len(mots)


def est_spam(message: str, seuil: float = 0.2) -> bool:
    """Classe le message comme indésirable si son score dépasse le seuil."""
    return score_spam(message) >= seuil


if __name__ == "__main__":
    exemples = [
        "Réunion de projet demain à 10h en salle B12.",
        "Urgent : cliquez ici pour recevoir votre cadeau gratuit !",
    ]
    for texte in exemples:
        print(f"{est_spam(texte)!s:>5}  {texte}")
