# Github runners

Docker image pro self-hosted github runnery. Kód převzat a upravit [odtud](https://github.com/beikeni/github-runner-dockerfile).

## Spuštění
- Před samotným spuštěním je potřeba získat `ACCESS_TOKEN`, který umožní se přihlásit
přes API na Github a tím vytvořit registrační token, kterým se následně přidá do repozitáře samotný runner.
Tento token potřebuje mít read & write administration role, aby se dostal
k [/actions/runners/registration-token](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository)
- Zkopírujte `env.env.sample` do `env.env` a doplňte jméno repozitáře, ke kterému se runner připojí (ve formátu `<organizace>/<repo>`, např. `fykosak/fksdb`).
- Spusťte build přes `docker compose build`.
- Spusťte runner přes `docker compose up`. Runner se automaticky spustí, zaregistruje se na github a připojí runnera do repozitáře.

## Produkce
Každý runner může najednou zpracovávat pouze jeden task. Proto pokud chceme
spouštět více úkolů paralelně, je potřeba vytvořit více runnerů. Kolik runnerů
poběží lze nastavit přímo v `docker-compose.yml` přes sekci `deploy`,
ve které je možné nastavit, kolik replikovaných kontejnerů poběží, případně
jim lze nastavit limity na použité prostředky serveru.

Pokud je v úmyslu self-hosted runnera použít, je potřeba změnit v daném
workflow `runs-on` na `selfhosted`, případně je možné použít různé [labels](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/using-self-hosted-runners-in-a-workflow).
