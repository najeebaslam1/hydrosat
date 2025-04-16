from setuptools import find_packages, setup

setup(
    name="hydrosat",
    packages=find_packages(),
    install_requires=["dagster", "dagit", "dagster-cloud", "pandas", "geopandas"],
    extras_require={"dev": ["dagster-webserver"]},
)
