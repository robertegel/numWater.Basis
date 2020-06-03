listfiles <- list.files()[grep("allModelsVersion1.7.variation",list.files())]
listfiles

for (file in listfiles) {
  source(file)
}
