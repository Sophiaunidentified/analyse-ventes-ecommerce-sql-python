
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("data-1795279675058.csv")

print(df.head())



# Transformation des dates en format Python
df["mois"] = pd.to_datetime(df["mois"])

# Création du graphique
plt.figure(figsize=(12, 6))
plt.plot(df["mois"], df["chiffre_affaires"], marker="o")

plt.title("Évolution du chiffre d'affaires mensuel (2009-2011)")
plt.xlabel("Mois")
plt.ylabel("Chiffre d'affaires (£)")
plt.grid(True)
plt.xticks(rotation=45)
plt.tight_layout()

# Enregistrement du graphique pour GitHub
plt.savefig("evolution_ca.png", dpi=300)

# Afficher le graphique
plt.show()



# TOP 10 des produits par chiffre d'affaires
produits = pd.read_csv("top_10_produits.csv")

plt.figure(figsize=(12, 6))
plt.barh(produits["produit"], produits["chiffre_affaires"])

plt.title("Top 10 des produits par chiffre d'affaires")
plt.xlabel("Chiffre d'affaires (£)")
plt.ylabel("Produits")
plt.gca().invert_yaxis()
plt.tight_layout()

plt.savefig("top_10_produits.png", dpi=300)
plt.show()



# TOP 10 des pays par chiffre d'affaires
pays = pd.read_csv("top_10_pays.csv")

plt.figure(figsize=(12, 6))
plt.barh(pays["pays"], pays["chiffre_affaires"])

plt.title("Top 10 des pays par chiffre d'affaires")
plt.xlabel("Chiffre d'affaires (£)")
plt.ylabel("Pays")
plt.gca().invert_yaxis()
plt.tight_layout()

# Enregistrement du graphique
plt.savefig("top_10_pays.png", dpi=300)

# Affichage du graphique
plt.show()
