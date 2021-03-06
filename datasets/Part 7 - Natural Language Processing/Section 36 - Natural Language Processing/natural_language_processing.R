# Natural Language Processing

# Importar el data set
dataset_original = read.delim("Restaurant_Reviews.tsv", quote = '',
                     stringsAsFactors = FALSE)

# Limpieza de textos
# install.packages("tm")
#install.packages("SnowballC")
library(tm)
library(SnowballC)
corpus = VCorpus(VectorSource(dataset_original$Review))
corpus = tm_map(corpus, content_transformer(tolower))

# Consultar el primer elemento del corpus
# as.character(corpus[[1]])
corpus = tm_map(corpus, removeNumbers)
corpus = tm_map(corpus, removePunctuation)
corpus = tm_map(corpus, removeWords, stopwords(kind = "en"))
corpus = tm_map(corpus, stemDocument)
corpus = tm_map(corpus, stripWhitespace)

# Crear el modelo Bag of Words
dtm = DocumentTermMatrix(corpus)
dtm = removeSparseTerms(dtm, 0.999)

dataset = as.data.frame(as.matrix(dtm))
dataset$Liked = dataset_original$Liked

# Codificar la variable de clasificación como factor
dataset$Liked = factor(dataset$Liked, levels = c(0,1))

# Dividir los datos en conjunto de entrenamiento y conjunto de test
# install.packages("caTools")

library(caTools)
set.seed(123)
split = sample.split(dataset$Liked, SplitRatio = 0.70)
training_set = subset(dataset, split == TRUE)
testing_set = subset(dataset, split == FALSE)

# Ajustar el Random Forest con el conjunto de entrenamiento.
#install.packages("randomForest")
library(randomForest)
classifier = randomForest(x = training_set[,-692],
                          y = training_set$Liked,
                          ntree = 10)

# Predicción de los resultados con el conjunto de testing
y_pred = predict(classifier, newdata = testing_set[,-692])

# Crear la matriz de confusión
cm = table(testing_set[, 692], y_pred)

tp = cm[1,1]
tn = cm[2,2]
fp = cm[1,2]
fn = cm[2,1]

accu = (tp+tn)/(tp+tn+fp+fn)
prec = tp/(tn+fp)
rec = tp/(tp+fn)
F1 = 2*prec*rec/(prec+rec)

cat('Random Forest:', 'Accuracy:',accu, 'Prec:', prec, 'Recall:', rec, 'F1:',F1)

## LOGISTIC REGRESSION

classifier = glm(formula = Liked ~ .,
                 data = training_set, 
                 family = binomial)

prob_pred = predict(classifier, type = "response",
                    newdata = testing_set[,-692])

y_pred = ifelse(prob_pred> 0.5, 1, 0)

cm = table(testing_set[, 692], y_pred)

tp = cm[1,1]
tn = cm[2,2]
fp = cm[1,2]
fn = cm[2,1]

accu = (tp+tn)/(tp+tn+fp+fn)
prec = tp/(tn+fp)
rec = tp/(tp+fn)
F1 = 2*prec*rec/(prec+rec)

cat('Logistic Reg:', 'Accuracy:',accu, 'Prec:', prec, 'Recall:', rec, 'F1:',F1)

## KNN Class
library(class)
y_pred = knn(train = training_set[,-692],
             test = testing_set[,-692],
             cl = training_set[,692], k = 10)

cm = table(testing_set[, 692], y_pred)

tp = cm[1,1]
tn = cm[2,2]
fp = cm[1,2]
fn = cm[2,1]

accu = (tp+tn)/(tp+tn+fp+fn)
prec = tp/(tn+fp)
rec = tp/(tp+fn)
F1 = 2*prec*rec/(prec+rec)

cat('KNN:', 'Accuracy:',accu, 'Prec:', prec, 'Recall:', rec, 'F1:',F1)

## SVM Linear
library(e1071)
classifier = svm(formula = Liked ~ ., 
                 data = training_set, type = "C-classification",
                 kernel = "linear")

y_pred = predict(classifier, newdata = testing_set[,-692])

cm = table(testing_set[, 692], y_pred)

tp = cm[1,1]
tn = cm[2,2]
fp = cm[1,2]
fn = cm[2,1]

accu = (tp+tn)/(tp+tn+fp+fn)
prec = tp/(tn+fp)
rec = tp/(tp+fn)
F1 = 2*prec*rec/(prec+rec)

cat('SVM Linear:', 'Accuracy:',accu, 'Prec:', prec, 'Recall:', rec, 'F1:',F1)

## SVM Radial

classifier = svm(formula = Liked~ .,
                 data = training_set, 
                 type = "C-classification", kernel = "radial")

y_pred = predict(classifier, newdata = testing_set[,-692])

cm = table(testing_set[, 692], y_pred)

tp = cm[1,1]
tn = cm[2,2]
fp = cm[1,2]
fn = cm[2,1]

accu = (tp+tn)/(tp+tn+fp+fn)
prec = tp/(tn+fp)
rec = tp/(tp+fn)
F1 = 2*prec*rec/(prec+rec)

cat('SVM Radial:', 'Accuracy:',accu, 'Prec:', prec, 'Recall:', rec, 'F1:',F1)

## NAIVE BAYES
classifier = naiveBayes(x = training_set[,-692], 
                        y = training_set$Liked)

y_pred = predict(classifier, newdata = testing_set[,-692])

cm = table(testing_set[, 692], y_pred)

tp = cm[1,1]
tn = cm[2,2]
fp = cm[1,2]
fn = cm[2,1]

accu = (tp+tn)/(tp+tn+fp+fn)
prec = tp/(tn+fp)
rec = tp/(tp+fn)
F1 = 2*prec*rec/(prec+rec)

cat('Naive Bayes:', 'Accuracy:',accu, 'Prec:', prec, 'Recall:', rec, 'F1:',F1)

## DECISION TREES
library(rpart)
classifier = rpart(formula = Liked ~ ., 
                   data = training_set)

y_pred = predict(classifier, newdata = testing_set[,-692],
                 type = "class")

cm = table(testing_set[, 692], y_pred)

tp = cm[1,1]
tn = cm[2,2]
fp = cm[1,2]
fn = cm[2,1]

accu = (tp+tn)/(tp+tn+fp+fn)
prec = tp/(tn+fp)
rec = tp/(tp+fn)
F1 = 2*prec*rec/(prec+rec)

cat('Decission Trees:', 'Accuracy:',accu, 'Prec:', prec, 'Recall:', 
    rec, 'F1:',F1)

## CART

library(caret)
library(rpart)

model1 <- train(y = training_set$Liked, x=training_set[,-692], 
               method = "rpart",
  trControl = trainControl("cv", number = 10),
  tuneLength = 10)
# Plot model accuracy vs different values of
# cp (complexity parameter)
# plot(model1)

y_pred = predict(model1, newdata = testing_set[,-692])

cm = table(testing_set[, 692], y_pred)

tp = cm[1,1]
tn = cm[2,2]
fp = cm[1,2]
fn = cm[2,1]

accu = (tp+tn)/(tp+tn+fp+fn)
prec = tp/(tn+fp)
rec = tp/(tp+fn)
F1 = 2*prec*rec/(prec+rec)

cat('RPART:', 'Accuracy:',accu, 'Prec:', prec, 'Recall:', 
    rec, 'F1:',F1)

## C50
library(C50)
model2 <- C5.0(x = training_set[, -692], y = training_set$Liked)
model2

y_pred = predict(model2, newdata = testing_set[,-692])

cm = table(testing_set[, 692], y_pred)

tp = cm[1,1]
tn = cm[2,2]
fp = cm[1,2]
fn = cm[2,1]

accu = (tp+tn)/(tp+tn+fp+fn)
prec = tp/(tn+fp)
rec = tp/(tp+fn)
F1 = 2*prec*rec/(prec+rec)

cat('C50:', 'Accuracy:',accu, 'Prec:', prec, 'Recall:', 
    rec, 'F1:',F1)
