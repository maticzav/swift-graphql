/*
  Warnings:

  - A unique constraint covering the columns `[userId,referenceId]` on the table `Star` will be added. If there are existing duplicate values, this will fail.
  - Changed the type of `referenceId` on the `Star` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- AlterTable
ALTER TABLE "Star" DROP COLUMN "referenceId",
ADD COLUMN     "referenceId" INTEGER NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Star_userId_referenceId_key" ON "Star"("userId", "referenceId");
