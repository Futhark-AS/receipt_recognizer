# Project Title

Receipt Recognizer

## Summary

Extracts data from an image of a receipt, storing it in a structured format.

## Background

This solves the problem of manually entering data from receipts. This can for example be used by those who want to have more accurate information about their spending. It is also possible to integrate the data extracted with any application that you build. My personal motivation for building this is to later be able to create an application where you can easily split a bill between friends, simply by dragging and dropping each item. Also, I want to learn more about neural networks. 

## How is it used?

To use the application, simply open the application and take or upload an image of a receipt. The application will then extract the data from the receipt, store it in a structured format and display it in a table.


## Data sources and AI methods

To extract the data, the Form Recognizer API from Azure Cognitive Services is used.

## Challenges

The model works best with receipts in big languages, such as English. It will not work well with receipts in all languages.

## What next?

The next step is to create an application where you can easily split a bill between friends, simply by dragging and dropping each item. In that way, you can easily keep track of who paid for what, and who owes what.

## Acknowledgments

This is the markdown template for the final project of the Building AI course, 
created by Reaktor Innovations and University of Helsinki.